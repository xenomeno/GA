dofile("GA_Common.lua")
dofile("GA_CompareSets.lua")
dofile("Bitmap.lua")
dofile("Graphics.lua")
dofile("CommonAI.lua")

local POPULATION_SIZE       = 30
local CHROMOSOME_LENGTH     = 30
local GENERATION_GAP        = 1       -- 1.0 means no overlaping populations
local CROWDING_FACTOR       = 2
local CROSSOVER_POINTS      = 1
local MINIMIZATION          = "DeJongF5"
local G_BIT_IMPROVE         = true

local CROSSOVER_RATE        = 0.6
local MAX_GENERATIONS       = 20
local FITNESS_SCALING       = false
local SIGMA_TRUNC           = false
local ROULETTE_WHEEL        = false
local RANK_SELECTION        = false
local PRINT_STATS           = false

local IMAGE_WIDTH           = 1280
local IMAGE_HEIGHT          = 720

-- recalculatable and depending on other params
local MUTATION_RATE         = false
local NORM_COEF             = false
local INIT_DEPRESSION       = false
local IMAGE_NAME            = false
local OBJECTIVE_FUNCTION    = false
local PLOT_FUNCTION         = false


local function RecalculateParams()
  MUTATION_RATE             = 1 / POPULATION_SIZE
  NORM_COEF                 = math.pow(2, CHROMOSOME_LENGTH) - 1
  IMAGE_NAME                = MINIMIZATION or "POW_10"
  OBJECTIVE_FUNCTION        = MINIMIZATION and _G[MINIMIZATION] or Pow10
  PLOT_FUNCTION             = MINIMIZATION and _G[MINIMIZATION .. "Plot"] or Pow10Plot
end

RecalculateParams()

local function Min(a, b)
  return (not a or b < a) and b or a
end

local function Max(a, b)
  return (not a or b > a) and b or a
end

function Pow10(chrom)
  return math.pow(chrom[1] / NORM_COEF, 10)
end

function Pow10Plot(x)
  return x
end

function DeJongF1(chrom)
  local x = ExtractBitstring(chrom, 1, 10)[1]
  local y = ExtractBitstring(chrom, 11, 10)[1]
  local z = ExtractBitstring(chrom, 21, 10)[1]
  
  x = -5.12 + 10.24 * x / 1024.0
  y = -5.12 + 10.24 * y / 1024.0
  z = -5.12 + 10.24 * z / 1024.0
  
  return x * x + y * y + z * z
end

function DeJongF1Plot(x)
  return x
end

local a1 = {-32,-16,0,16,32,-32,-16,0,16,32,-32,-16,0,16,32,-32,-16,0,16,32,-32,-16,0,16,32}
local a2 = {-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32,-32}

function DeJongF5(chrom)
  local x1 = ExtractBitstring(chrom, 1, 15)[1]
  local x2 = ExtractBitstring(chrom, 16, 30)[1]
  
  x1 = -65.536 + 131.072 * x1 / 32768.0
  x2 = -65.536 + 131.072 * x2 / 32768.0
  
  local sum = 0.002
  for i = 1, 25 do
    sum = sum + 1.0 / (i + math.pow(x1 - a1[i], 6) + math.pow(x2 - a2[i], 6))
  end

  return 1.0 / sum
end

function DeJongF5Plot(x)
  return x
end

local function GenRandomChromoze(len)
  local bits = {}
  for i = 1, len do
    bits[i] = FlipCoin(0.5) and "1" or "0"
  end
  
  return table.concat(bits, "")
end

local function EvaluateChromosome(chrom)
  return OBJECTIVE_FUNCTION(chrom)
end

local function GenInitPopulation(size, chromosome_len)
  local population = { crossovers = 0, mutations = 0}
  for i = 1, size do
    local bitstring = GenRandomChromoze(chromosome_len)
    local chrom_words = PackBitstring(bitstring)
    while (MINIMIZATION and EvaluateChromosome(chrom_words) < INIT_DEPRESSION) or (not MINIMIZATION and EvaluateChromosome(chrom_words) > INIT_DEPRESSION) do
      bitstring = GenRandomChromoze(chromosome_len)
      chrom_words = PackBitstring(bitstring)
    end
    population[i] = { chromosome = chrom_words, fitness = 0.0, objective = 0.0 }
  end
  
  return population
end

local function GBitImprove(pop)
  local func = MINIMIZATION and table.min or table.max
  local best, best_idx = func(pop, function(individual) return individual.objective end)
  local chrom = best.chromosome
  local altered_chrom = CopyBitstring(chrom)
  local better_chrom, better_objective = CopyBitstring(chrom), best.objective
  local word_size = GetBitstringWordSize()
  local word_idx, bit_pos, power2 = 1, 1, 1
  for bit = 1, chrom.bits do
    local word, altered_word = chrom[word_idx], altered_chrom[word_idx]
    local allele = (word & power2) ~= 0
    altered_chrom[word_idx] = allele and (word - power2) or (word + power2)
    local objective = EvaluateChromosome(altered_chrom)
    if (MINIMIZATION and objective < better_objective) or (not MINIMIZATION and objective > better_objective) then
      better_objective = objective
      better_chrom = CopyBitstring(altered_chrom)
    end
    altered_chrom[word_idx] = altered_word
    bit_pos, power2 = bit_pos + 1, power2 * 2
    if bit_pos > word_size then
      word_idx, bit_pos, power2 = word_idx + 1, 1, 1
    end
  end
  local old_objective = best.objective
  if better_objective ~= best.objective then
    pop[best_idx].chrom = better_chrom
    pop[best_idx].objective = better_objective
  end
  
  return old_objective, better_objective
end

local s_BiggestValue = false

-- NOTE: evaluates partial total fitness per each individual(which becomes in sorted order)
--       later will permit performing binary search in the Roulette Wheel Selection
local function EvaluatePopulation(pop, old_pop, gen)
  -- calculated objective by decoding chromozomes
  local total_objective, min_objective, max_objective = 0.0
  for _, individual in ipairs(pop) do
    local objective = EvaluateChromosome(individual.chromosome)
    min_objective = Min(min_objective, objective)
    max_objective = Max(max_objective, objective)
    individual.objective = objective
    total_objective = total_objective + objective
  end
  if G_BIT_IMPROVE then
    local old_objective, better_objective = GBitImprove(pop)
    if old_objective ~= better_objective then
      min_objective = Min(min_objective, better_objective)
      max_objective = Max(max_objective, better_objective)
      total_objective = total_objective - old_objective + better_objective
    end
  end
  pop[0] = { objective = 0.0 }
  pop.total_objective = total_objective
  pop.avg_objective = total_objective / #pop
  pop.min_objective, pop.max_objective = min_objective, max_objective
  
  if MINIMIZATION then
    s_BiggestValue = Max(s_BiggestValue, max_objective)
    s_BiggestValue = max_objective
  end
  
  -- calculate raw fitness
  local total_raw_fitness, min_raw_fitness, max_raw_fitness = 0.0
  for _, individual in ipairs(pop) do
    local raw_fitness = MINIMIZATION and (s_BiggestValue - individual.objective) or individual.objective
    min_raw_fitness = Min(min_raw_fitness, raw_fitness)
    max_raw_fitness = Max(max_raw_fitness, raw_fitness)
    individual.raw_fitness = raw_fitness
    total_raw_fitness = total_raw_fitness + raw_fitness
  end
  pop.total_raw_fitness = total_raw_fitness
  pop.avg_raw_fitness = total_raw_fitness / #pop
  pop.min_raw_fitness, pop.max_raw_fitness = min_raw_fitness, max_raw_fitness
  
  -- calculate population variance and standard deviation
  local var = 0.0
  for _, individual in ipairs(pop) do
    local diff = individual.raw_fitness - pop.avg_raw_fitness
    var = var + diff * diff
  end
  var = var / (#pop - 1)    -- N-1 for Bessel's correction
  pop.var = var
  pop.dev = math.sqrt(var)

  pop[0].fitness, pop[0].part_total_fitness = 0.0, 0.0
  local total_fitness, min_fitness, max_fitness = 0.0
  for _, individual in ipairs(pop) do
    local fitness = individual.raw_fitness
    if FITNESS_SCALING and SIGMA_TRUNC then
      fitness = fitness - (pop.avg_raw_fitness - SIGMA_TRUNC * pop.dev)
      fitness = (fitness < 0) and 0 or fitness
    end
    individual.fitness = fitness
    individual.part_total_fitness = total_fitness
    total_fitness = total_fitness + fitness
    min_fitness = Min(min_fitness, fitness)
    max_fitness = Max(max_fitness, fitness)
  end
  pop.total_fitness = total_fitness
  pop.avg_fitness = total_fitness / #pop
  pop.min_fitness, pop.max_fitness = min_fitness, max_fitness
  
  if RANK_SELECTION then
    -- NOTE: when using rank instead of fitness population should be sorted by rank for the binary search to work
    table.sort(pop, function(individual1, individual2) return individual1.fitness > individual2.fitness end)
    local total_rank = 0.0
    for idx, individual in ipairs(pop) do
      local rank = 1.0 / math.sqrt(idx * idx)
      individual.rank = rank
      individual.part_total_rank = total_rank
      total_rank = total_rank + rank
    end
    pop.total_rank = total_rank
  end
  
  -- calculate interim performance
  local current = MINIMIZATION and pop.min_objective or pop.max_objective
  if old_pop then
    pop.interim_performance = (old_pop.interim_performance * (gen - 1) + current) / gen
    if MINIMIZATION then
      pop.ultimate_performance = Min(current, old_pop.ultimate_performance)
    else
      pop.ultimate_performance = Max(current, old_pop.ultimate_performance)
    end
  else
    pop.interim_performance = current
    pop.ultimate_performance = current
  end
end

-- maps objective function to fitness using [F1=a*F+b] by scaling so [F1max=scale*Favg, F1avg=Favg]
local function ScalePopulation(pop, scale, old_pop, gen)
  scale = scale or 2.0
  
  local Omin, Oavg, Omax = pop.min_fitness, pop.avg_fitness, pop.max_fitness
  local a, b
  if Omin <= (scale * Oavg - Omax) / (scale - 1.0) then   -- check if F1min will be negative
    -- scale as much as we can
    local delta = Oavg - Omin
    a = Oavg / delta
    b = -Omin * Oavg / delta
  else
    -- normal scaling
    local delta = Omax - Oavg
    a = (scale - 1.0) * Oavg / delta
    b = (Omax - scale * Oavg) * Oavg / delta
  end

  pop[0].fitness, pop[0].part_total_fitness = 0.0, 0.0
  local total_fitness, min_fitness, max_fitness = 0
  for _, individual in ipairs(pop) do
    local fitness = a * individual.fitness + b
    individual.fitness = fitness
    individual.part_total_fitness = total_fitness
    total_fitness = total_fitness + fitness
    min_fitness = Min(min_fitness, fitness)
    max_fitness = Max(max_fitness, fitness)
  end
  pop.total_fitness = total_fitness
  pop.avg_fitness = pop.total_fitness / #pop
  pop.min_fitness, pop.max_fitness = min_fitness, max_fitness
end

local function PrintPopulation(pop, gen, new_pop)
  if not PRINT_STATS then return end
  
  if gen then
    print(string.format("Population at generation %d", gen))
  else
    print("Initial population")
  end
  local str = "Idx: Chromosomes";
  if new_pop then
    local spaces = string.rep(" ", CHROMOSOME_LENGTH + 5 - string.len(str))
    local spaces2 = spaces .. string.rep(" " , string.len(str))
    local obj = string.format("Objective:%.2f(Total)", pop.total_objective)
    obj = string.rep(" ", 27 - string.len(obj)) .. obj
    str = string.format("%s%s[Words     ]   %s|Idx: ( p1, p2)  XSite  Chromosomes %sObj:%.2f(Total)", str, spaces, obj, spaces2, new_pop.total_objective)
  else
    local spaces = string.rep(" ", CHROMOSOME_LENGTH + 5 - string.len(str))
    str = string.format("%s%s[Words     ]     Objective:%.2f(Total)", str, spaces, pop.total_objective)
  end
  local stats = string.format("Min: %.4f, Max: %.4f, Avg: %.4f,  Crossovers: %d, Mutations: %d", pop.min_objective, pop.max_objective, pop.avg_objective, pop.crossovers, pop.mutations)
  if new_pop then
    local divide = string.find(str, "|")
    stats = stats .. string.rep(" ", divide - string.len(stats) - 1) .. "|"
    stats = string.format("%s Min: %.4f, Max: %.4f, Avg: %.4f,  Crossovers: %d, Mutations: %d", stats, new_pop.min_objective, new_pop.max_objective, new_pop.avg_objective, new_pop.crossovers, new_pop.mutations)
  end
  local dashes = string.rep("-", string.len(str))
  
  print(dashes)
  print(str)
  print(dashes)
  for idx, individual in ipairs(pop) do
    local individual_new = new_pop and new_pop[idx]
    local words, words_new = {}, {}
    for k = 1, #individual.chromosome do
      words[k] = string.format("%10d", individual.chromosome[k])
      words_new[k] = new_pop and string.format("%10d", individual_new.chromosome[k]) or ""
    end
    words = table.concat(words, ",")
    words_new = table.concat(words_new, ",")
    if new_pop then
      local parent1 = individual_new.parent1 and string.format("% 3d", individual_new.parent1) or "---"
      local parent2 = individual_new.parent2 and string.format("% 3d", individual_new.parent2) or "---"
      local xsite = individual_new.xsite and string.format("% 3d", individual_new.xsite) or "---"
      local obj = string.format("%.20f", individual.objective)
      obj = string.rep(" ", 24 - string.len(obj)) .. obj
      print(string.format("% 3d: %s[%s]     %s |% 3d: (%s,%s)   %s   %s[%s]     %.20f", idx, UnpackBitstring(individual.chromosome), words, obj, idx, parent1, parent2, xsite, UnpackBitstring(individual_new.chromosome), words_new, individual_new.objective))
    else
      print(string.format("% 3d: %s[%s]     %.20f", idx, UnpackBitstring(individual.chromosome), words, individual.objective))
    end
  end
  print(dashes)
  print(str)
  print(stats)
  print(dashes)
end

local function PlotPopulation(funcs, gen, pop)
  if pop then
    funcs["Max"][gen].y = funcs["Max"][gen].y + PLOT_FUNCTION(pop.max_objective)
    funcs["Min"][gen].y = funcs["Min"][gen].y + PLOT_FUNCTION(pop.min_objective)
    funcs["Avg"][gen].y = funcs["Avg"][gen].y + PLOT_FUNCTION(pop.avg_objective)
    funcs["Dev"][gen].y = funcs["Dev"][gen].y + PLOT_FUNCTION(pop.dev)
    funcs["Var"][gen].y = funcs["Var"][gen].y + PLOT_FUNCTION(pop.var)
    funcs["Interim"][gen].y = funcs["Interim"][gen].y + PLOT_FUNCTION(pop.interim_performance)
    funcs["Ultimate"][gen].y = funcs["Ultimate"][gen].y + PLOT_FUNCTION(pop.ultimate_performance)
  else
    for k = 1, gen do
      funcs["Max"][k] = { x = k, y = 0.0 }
      funcs["Min"][k] = { x = k, y = 0.0 }
      funcs["Avg"][k] = { x = k, y = 0.0 }
      funcs["Dev"][k] = { x = k, y = 0.0 }
      funcs["Var"][k] = { x = k, y = 0.0 }
      funcs["Interim"][k] = { x = k, y = 0.0 }
      funcs["Ultimate"][k] = { x = k, y = 0.0 }
    end
  end
end

local function SelectionRouletteWheel(pop)
  local total = RANK_SELECTION and pop.total_rank or pop.total_fitness
  local prop = RANK_SELECTION and "part_total_rank" or "part_total_fitness"
  local slot = math.random() * total
  if slot <= 0 then
    return 1
  elseif slot >= total then
    return #pop
  end
  
  local left, right = 1, #pop
  while left + 1 < right do
    local middle = (left + right) // 2
    local part_total = pop[middle][prop]
    if slot == part_total then
      return middle
    elseif slot < part_total then
      right = middle
    else
      left = middle
    end
  end
  
  local prop_value = RANK_SELECTION and pop[left].rank or pop[left].fitness
  
  return (slot < pop[left][prop] + prop_value) and left or right
end

local function PreSelectionStochasticRemainderNoReplacement(pop)
  -- preselect
  local avg_fitness = pop.avg_fitness
  local pop_size = #pop
  local choices, fraction = {}, {}
  local mean = #pop // 2
  for idx, chromosome in ipairs(pop) do
    local expected
    if RANK_SELECTION then
      if idx <= mean then
        expected = RANK_SELECTION - (RANK_SELECTION - 1) * (idx - 1) / (mean - 1)
      else
        expected = 1 / (#pop - mean)
      end
    else
      expected = chromosome.fitness / avg_fitness
    end
    local integer = math.floor(expected)
    fraction[idx] = expected - integer
    while integer > 0 do
      table.insert(choices, idx)
      integer = integer - 1
    end
  end
  
  -- Bernoulli trials with the fractions to fill up the population choices
  local k = 0
  while #choices < pop_size do
    k = (k < pop_size) and (k + 1) or 1
    if fraction[k] > 0 and FlipCoin(fraction[k]) then
      table.insert(choices, k)
      fraction[k] = fraction[k] - 1
    end
  end
  
  return choices
end

local function SelectionStochasticRemainderNoReplacement(choices)
  if #choices == 0 then return end
  
  local idx = math.random(1, #choices)
  local mate = choices[idx]
  choices[idx] = choices[#choices]
  table.remove(choices)
  
  return mate
end

local function GetXSites(cp_count, chrom_length)
  local xsites = { marked = { [false] = true } }
  for cp = 1, cp_count do
    local xsite = false
    while xsites.marked[xsite] do xsite = math.random(1, chrom_length) end
    xsites[cp], xsites.marked[xsite] = xsite, true
  end
  xsites.marked = nil
  if #xsites > 1 then
    table.sort(xsites)
  end
  if (cp_count & 1) == 1 then
    -- make them always even by adding 1st/last position as a cross site
    table.insert(xsites, cp_count + 1)
  end
  
  return xsites
end

local function Crossover(mate1, mate2)
  local offspring1 = { chromosome = CopyBitstring(mate1.chromosome) }
  local offspring2 = { chromosome = CopyBitstring(mate2.chromosome) }
  
  local crossover = FlipCoin(CROSSOVER_RATE)
  if crossover then
    if CROSSOVER_POINTS == 1 then
      -- simple 1-point crossover
      local xsite = math.random(1, CHROMOSOME_LENGTH)
      ExchangeTailBits(offspring1.chromosome, offspring2.chromosome, xsite)
      offspring1.xsite = xsite
      offspring2.xsite = xsite
    else
      -- threat chromosome as a ring
      local xsites = GetXSites(CROSSOVER_POINTS, CHROMOSOME_LENGTH)
      for cp = 1, CROSSOVER_POINTS, 2 do
        local xsite1, xsite2 = xsites[cp], xsites[cp + 1]
        ReplaceBitstring(offspring1.chromosome, xsite1, mate2.chromosome, xsite1, xsite2 - xsite1)
        ReplaceBitstring(offspring2.chromosome, xsite1, mate1.chromosome, xsite1, xsite2 - xsite1)
      end
    end
  end
  
  return offspring1, offspring2, crossover
end

local function Mutate(offspring)
  local mutations = 0
  
  local chromosome = offspring.chromosome
  local word_idx, bit_pos, power2 = 1, 1, 1
  for bit = 1, chromosome.bits do
    if FlipCoin(MUTATION_RATE) then
      local word = chromosome[word_idx]
      local allele = word & power2
      chromosome[word_idx] = (allele ~= 0) and (word - power2) or (word + power2)
      mutations = mutations + 1
    end
    bit_pos = bit_pos + 1
    power2 = power2 * 2
    if bit_pos > GetBitstringWordSize() then
      word_idx = word_idx + 1
      bit_pos, power2 = 1, 1
    end
  end
  
  return mutations
end

local function ReplaceMostSimilar(pop, offspring, avail_indices)
  local crowd = { marked = {} }
  for k = 1, CROWDING_FACTOR do
    local avail_idx = math.random(1, #avail_indices)
    while crowd.marked[avail_idx] do
      avail_idx = math.random(1, #avail_indices)
    end
    crowd.marked[avail_idx] = true
    table.insert(crowd, avail_idx)
  end
  
  local most_similar, max_bits
  for _, avail_idx in ipairs(crowd) do
    local pop_idx = avail_indices[avail_idx]
    local individual = pop[pop_idx]
    local bits = GetCommonBits(individual.chromosome, offspring.chromosome)
    if (not most_similar) or (bits > max_bits) then
      most_similar = avail_idx
      max_bits = bits
    end
  end
  
  local pop_die_idx = avail_indices[most_similar]
  avail_indices[most_similar] = avail_indices[#avail_indices]
  table.remove(avail_indices)
  
  -- new offspring replaces the most similar in the population
  pop[pop_die_idx] = offspring
end

local function RunSGA(set, max_generations)
  max_generations = max_generations or MAX_GENERATIONS
  
  local start_clock = os.clock()
  
  local to_plot = {}
  for idx, plot in ipairs(set.plots) do
    to_plot[idx] = { image = plot.image, funcs = {}, name_x = "Generation Number", name_y = "Objective" }
  end
  for set_idx, descr in ipairs(set) do
    if descr.size then POPULATION_SIZE = descr.size end
    MINIMIZATION = descr.minimization
    ROULETTE_WHEEL = not not descr.roulette_wheel
    if descr.rank_selection then RANK_SELECTION = descr.rank_selection else RANK_SELECTION = false end
    if descr.fitness_scaling then FITNESS_SCALING = descr.fitness_scaling else FITNESS_SCALING = false end
    if descr.sigma_trunc then SIGMA_TRUNC = descr.sigma_trunc else SIGMA_TRUNC = false end
    if descr.generation_gap then GENERATION_GAP = descr.generation_gap else GENERATION_GAP = 1.0 end
    if descr.crowding_factor then CROWDING_FACTOR = descr.crowding_factor else CROWDING_FACTOR = false end
    if descr.gbit_improve then G_BIT_IMPROVE = descr.gbit_improve else G_BIT_IMPROVE = false end
    INIT_DEPRESSION = set.init_depression or (MINIMIZATION and 400.0 or 0.1)
    RecalculateParams()
    print(string.format("#%d/%d, %s: %s%s, n=%d, gens=%d%s", set_idx, #set, MINIMIZATION or "Max", ROULETTE_WHEEL and "RWS" or "SRSWR", RANK_SELECTION and "[Rank]" or "", POPULATION_SIZE, MAX_GENERATIONS, FITNESS_SCALING and string.format(", FS=%.3f", FITNESS_SCALING) or ""))
    
    local plot_funcs =
    {
      ["Max"] = { color = {255, 0, 0} },
      ["Min"] = { color = {0, 0, 255} },
      ["Avg"] = { color = {0, 255, 0} },
      ["Dev"] = { color = {255, 255, 255} },
      ["Var"] = { color = {128, 128, 128} },
      ["Interim"] = { color = { 164, 164, 164 } },
      ["Ultimate"] = { color = { 255, 255, 255 } },
    }
    PlotPopulation(plot_funcs, max_generations)
    
    for run = 1, set.runs do
      if run % 5 == 0 then
        print(string.format("Run %d/%d", run, set.runs))
      end
      
      local init_pop = GenInitPopulation(POPULATION_SIZE, CHROMOSOME_LENGTH)
      EvaluatePopulation(init_pop)
      if FITNESS_SCALING then
        ScalePopulation(init_pop, FITNESS_SCALING)
      end
      PrintPopulation(init_pop)
      PlotPopulation(plot_funcs, 1, init_pop)
      
      local pop = init_pop
      local overlap_count = math.ceil(POPULATION_SIZE * GENERATION_GAP)
      local crossovers, mutations = 0, 0
      for gen = 2, max_generations do    
        local new_pop = { crossovers = pop.crossovers, mutations = pop.mutations}
        local choices = (not ROULETTE_WHEEL) and PreSelectionStochasticRemainderNoReplacement(pop)
        while #new_pop < overlap_count do
          -- selection
          local idx1, idx2
          if ROULETTE_WHEEL then
            idx1 = SelectionRouletteWheel(pop)
            idx2 = SelectionRouletteWheel(pop)
          else
            idx1 = SelectionStochasticRemainderNoReplacement(choices)
            idx2 = SelectionStochasticRemainderNoReplacement(choices) or idx1   -- in case odd population size
          end
          
          -- crossover
          local offspring1, offspring2, crossover = Crossover(pop[idx1], pop[idx2])
          new_pop.crossovers = new_pop.crossovers + (crossover and 1 or 0)
          
          -- mutation
          local mut1 = Mutate(offspring1)
          local mut2 = Mutate(offspring2)
          
          -- store ancestry tree
          offspring1.parent1, offspring1.parent2 = idx1, idx2
          offspring2.parent1, offspring2.parent2 = idx1, idx2
          table.insert(new_pop, offspring1)
          new_pop.mutations = new_pop.mutations + mut1
          if #new_pop < POPULATION_SIZE then
            -- shield in case population size is odd
            table.insert(new_pop, offspring2)
            new_pop.mutations = new_pop.mutations + mut2
          end
        end
        
        if overlap_count < POPULATION_SIZE then
          local old_pop =
          {
            mutations = pop.mutations, crossovers = pop.crossovers,
            min_objective = pop.min_objective, max_objective = pop.max_objective,
            avg_objective = pop.avg_objective, total_objective = pop.total_objective,
            interim_performance = pop.interim_performance, ultimate_performance = pop.ultimate_performance,
          }
          local avail_indices = {}
          for idx, individual in ipairs(pop) do
            old_pop[idx] = pop[idx]
            avail_indices[idx] = idx
          end
          for _, offspring in ipairs(new_pop) do
            -- select most similar individual(using CROWDING_FACTOR) to die and be replaced by the new offsprings
            ReplaceMostSimilar(pop, offspring, avail_indices)
          end
          EvaluatePopulation(pop, old_pop, gen)
          if FITNESS_SCALING then
            ScalePopulation(pop, FITNESS_SCALING, old_pop, gen)
          end
          pop.crossovers, pop.mutations = new_pop.crossovers, new_pop.mutations
          PrintPopulation(old_pop, gen, pop)
        else      
          EvaluatePopulation(new_pop, pop, gen)
          if FITNESS_SCALING then
            ScalePopulation(new_pop, FITNESS_SCALING, pop, gen)
          end
          PrintPopulation(pop, gen, new_pop)
          pop = new_pop
        end
        
        PlotPopulation(plot_funcs, gen, pop)
      end   -- max generations
    end   -- runs
    for name, points in pairs(plot_funcs) do
      for gen = 1, max_generations do
        points[gen].y = points[gen].y / set.runs
      end
    end
    
    local name = string.format_table(set.func_name, descr, set.num_fmt)
    for idx, plot in ipairs(set.plots) do
      local graph = plot_funcs[plot.graph]
      graph.color = descr.color
      to_plot[idx].funcs[name] = graph
    end
  end -- tests
  
  local time = os.clock() - start_clock
  local time_text = string.format("Time (Lua 5.3): %ss", time)
  print(time_text)
  
  for _, plot in ipairs(to_plot) do
    local filename = string.format("GA/SGA_%s_gens%d.bmp", plot.image, max_generations)
    print(string.format("Writinng '%s'...", filename))
    local bmp = Bitmap.new(IMAGE_WIDTH, IMAGE_HEIGHT, {0, 0, 0})
    DrawGraphs(bmp, plot, nil, nil, "int x", nil, "skip KP")
    local tw, th = bmp:MeasureText(time_text)
    bmp:DrawText(IMAGE_WIDTH - tw - 5, 5, time_text, {128, 128, 128})
    tw, th = bmp:MeasureText(set.test_name)
    bmp:DrawText((IMAGE_WIDTH - tw) // 2, 5, set.test_name, {128, 128, 128})
    local runs = string.format("Runs=%d", set.runs)
    tw, th = bmp:MeasureText(runs)
    bmp:DrawText(0, IMAGE_HEIGHT - 1 - th, runs, {128, 128, 128})
    bmp:WriteBMP(filename)
  end
end

RunSGA(GA_CompareSets.Max_GBitImprove)
--for _, set in pairs(GA_CompareSets) do RunSGA(set) end    -- uncomment this to run all the tests