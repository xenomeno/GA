dofile("GA_Common.lua")
dofile("Bitmap.lua")
dofile("Graphics.lua")

local POPULATION_SIZE     = 30
local CHROMOZOME_LENGTH   = 10
local CROSSOVER_RATE      = 0.6
local MUTATION_RATE       = 1 / POPULATION_SIZE
local NORM_COEF           = math.pow(8, CHROMOZOME_LENGTH) - 1
local MINIMIZATION        = false
local INIT_DEPRESSION     = MINIMIZATION and 100000.0 or 0.6
local MAX_GENERATIONS     = 20
local GRAPH_GEN_INTERVAL  = 1
local FITNESS_SCALING     = false
local PRINT_STATS         = false

local IMAGE_WIDTH         = 640
local IMAGE_HEIGHT        = 480
local IMAGE_NAME          = MINIMIZATION and "OCTAL_TRIPLE_QUADR" or "OCTAL_POW_10"

local function OctToDeg(octals)
  local len = string.len(octals)
  
  local value, power8, pos = 0, 1, 1
  for i = 1, len do
    local allele = tonumber(string.sub(octals, i, i))
    value = value + allele * power8
    power8 = power8 * 8
  end
  
  return value
end

local function Pow10(chrom)
  return math.pow(OctToDeg(chrom) / NORM_COEF, 10)
end

local function Pow10Plot(x)
  return x
end

local function TripleQuadratic(chrom)
  local x = OctToDeg(string.sub(chrom, 1, 3))
  local y = OctToDeg(string.sub(chrom, 4, 6))
  local z = OctToDeg(string.sub(chrom, 7, 9))
  
  return x * x + y * y + z * z
end

local function TripleQuadraticPlot(x)
  return math.sqrt(x)
end

local OBJECTIVE_FUNCTION  = MINIMIZATION and TripleQuadratic or Pow10
local PLOT_FUNCTION       = MINIMIZATION and TripleQuadraticPlot or Pow10Plot

local function GenRandomChromoze(len)
  local octals = {}
  for i = 1, len do
    octals[i] = math.random(0, 7)
  end
  
  return table.concat(octals, "")
end

local function EvaluateChromozome(chrom)
  return OBJECTIVE_FUNCTION(chrom)
end

local function GenInitPopulation(size, chromozome_len)
  local population = { crossovers = 0, mutations = 0}
  for i = 1, size do
    local chromozome = GenRandomChromoze(chromozome_len)
    while (MINIMIZATION and EvaluateChromozome(chromozome) < INIT_DEPRESSION) or (not MINIMIZATION and EvaluateChromozome(chromozome) > INIT_DEPRESSION) do
      chromozome = GenRandomChromoze(chromozome_len)
    end
    population[i] = { chromozome = chromozome, fitness = 0.0, objective = 0.0 }
  end
  
  return population
end

local s_BiggestValue = false

-- NOTE: evaluates partial total fitness per each individual(which becomes in sorted order)
--       later will permit performing binary search in the Roulette Wheel Selection
local function EvaluatePopulation(pop)
  local total_objective, min_objective, max_objective = 0.0
  for _, individual in ipairs(pop) do
    local objective = EvaluateChromozome(individual.chromozome)
    min_objective = (not min_objective or objective < min_objective) and objective or min_objective
    max_objective = (not max_objective or objective > max_objective) and objective or max_objective
    individual.objective = objective
    total_objective = total_objective + objective
  end
  pop[0] = { objective = 0.0, part_total_fitness = 0.0 }
  pop.total_objective = total_objective
  pop.avg_objective = total_objective / #pop
  pop.min_objective, pop.max_objective = min_objective, max_objective
  
  if MINIMIZATION then
    s_BiggestValue = (not s_BiggestValue or max_objective > s_BiggestValue) and max_objective or s_BiggestValue
    s_BiggestValue = max_objective
  end
  
  -- initially objective and fitness are equal(later scaling my change the later)
  pop[0].fitness = MINIMIZATION and (s_BiggestValue - pop[0].objective) or pop[0].objective
  local total_fitness = 0.0
  for _, individual in ipairs(pop) do
    individual.fitness =  MINIMIZATION and (s_BiggestValue - individual.objective) or individual.objective
    individual.part_total_fitness = total_fitness
    total_fitness = total_fitness + individual.fitness
  end
  pop.total_fitness = total_fitness
  pop.avg_fitness = total_fitness / POPULATION_SIZE
  pop.min_fitness = MINIMIZATION and (s_BiggestValue - pop.min_objective) or pop.min_objective
  pop.max_fitness = MINIMIZATION and (s_BiggestValue - pop.max_objective) or pop.max_objective
end

-- maps objective function to fitness using [F1=a*F+b] by scaling so [F1max=scale*Favg, F1avg=Favg]
local function ScalePopulation(pop, scale)
  scale = scale or 2.0
  
  local Omin, Oavg, Omax = pop.min_objective, pop.avg_objective, pop.max_objective
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

  for _, individual in ipairs(pop) do
    individual.fitness = a * individual.objective + b
    individual.part_total_fitness = a * individual.part_total_fitness + b
  end
  pop[0].fitness, pop[0].part_total_fitness = b, b
  pop.total_fitness = a * pop.total_objective + b
  pop.avg_fitness = a * pop.avg_objective + b
  pop.min_fitness = a * pop.min_objective + b
  pop.max_fitness = a * pop.max_objective + b
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
    local spaces = string.rep(" ", CHROMOZOME_LENGTH + 5 - string.len(str))
    local spaces2 = spaces .. string.rep(" " , string.len(str))
    str = string.format("%s%s     Objective:%.2f(Total)   | Idx: ( p1, p2)  XSite  Chromosomes %sObjective:%.2f(Total)", str, spaces, pop.total_objective, spaces2, new_pop.total_objective)
  else
    local spaces = string.rep(" ", CHROMOZOME_LENGTH + 5 - string.len(str))
    str = string.format("%s%s     Objective:%.2f(Total)", str, spaces, pop.total_objective)
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
    if new_pop then
      print(string.format("% 3d: %s     %.20f  |  % 3d: (% 3d,% 3d)   %s   %s     %.20f", idx, individual.chromozome, individual.objective, idx, individual_new.parent1, individual_new.parent2, individual_new.xsite and string.format("% 3d", individual_new.xsite) or "---", individual_new.chromozome, individual_new.objective))
    else
      print(string.format("% 3d: %s     %.20f", idx, individual.chromozome, individual.objective))
    end
  end
  print(dashes)
  print(str)
  print(stats)
  print(dashes)
end

local function SelectionRouletteWheel(pop)
  local slot = math.random() * pop.total_fitness
  if slot <= pop[1].fitness then
    return 1
  elseif slot >= pop.total_fitness then
    return #pop
  end
  
  local left, right = 1, #pop
  while left + 1 < right do
    local middle = (left + right) // 2
    local fitness = pop[middle].part_total_fitness
    if slot == fitness then
      return middle
    elseif slot < fitness then
      right = middle
    else
      left = middle
    end
  end
  
  return (slot < pop[left].part_total_fitness + pop[left].fitness) and left or right
end

local function Crossover(mate1, mate2)
  local offspring1 = { chromozome = mate1.chromozome }
  local offspring2 = { chromozome = mate2.chromozome }
  
  local crossover = FlipCoin(CROSSOVER_RATE)
  if crossover then
    local xsite = math.random(1, CHROMOZOME_LENGTH)
    local str1 = string.sub(offspring1.chromozome, 1, xsite - 1) .. string.sub(offspring2.chromozome, xsite, string.len(offspring2.chromozome))
    local str2 = string.sub(offspring2.chromozome, 1, xsite - 1) .. string.sub(offspring1.chromozome, xsite, string.len(offspring1.chromozome))
    offspring1.chromosome = str1
    offspring2.chromosome = str2
    offspring1.xsite = xsite
    offspring2.xsite = xsite
  end
  
  return offspring1, offspring2, crossover
end

local function Mutate(offspring)
  local mutations = 0
  
  local chromozome = offspring.chromozome
  local new = {}
  for bit = 1, string.len(chromozome) do
    local allele = string.sub(chromozome, bit, bit)
    if FlipCoin(MUTATION_RATE) then
      local allele = tonumber(allele) + math.random(1, 7)
      if allele > 7 then
        allele = allele - 8
      end
      new[bit] = allele
      mutations = mutations + 1
    else
      new[bit] = allele
    end
  end
  
  return { chromozome = table.concat(new, "") }, mutations
end

local function RunSGA(max_generations)
  max_generations = max_generations or MAX_GENERATIONS
  
  local start_clock = os.clock()
  
  local init_pop = GenInitPopulation(POPULATION_SIZE, CHROMOZOME_LENGTH)
  EvaluatePopulation(init_pop)
  if FITNESS_SCALING then
    ScalePopulation(init_pop, FITNESS_SCALING)
  end
  PrintPopulation(init_pop)
  
  local graphs =
  {
    name_x = "Generation Number",
    name_y = "Objective",
    funcs =
    {
      ["Max"] = { color = {255, 0, 0} },
      ["Min"] = { color = {0, 0, 255} },
      ["Avg"] = { color = {0, 255, 0} },
    },
  }
  table.insert(graphs.funcs.Max, {x = 0, y = PLOT_FUNCTION(init_pop.max_objective) })
  table.insert(graphs.funcs.Min, {x = 0, y = PLOT_FUNCTION(init_pop.min_objective) })
  table.insert(graphs.funcs.Avg, {x = 0, y = PLOT_FUNCTION(init_pop.avg_objective) })

  local pop = init_pop
  local crossovers, mutations = 0, 0
  for gen = 1, max_generations do
    local new_pop = { crossovers = pop.crossovers, mutations = pop.mutations}
    while #new_pop < POPULATION_SIZE do
      -- selection
      local idx1 = SelectionRouletteWheel(pop)
      local idx2 = SelectionRouletteWheel(pop)
      
      -- crossover
      local offspring1, offspring2, crossover = Crossover(pop[idx1], pop[idx2])
      new_pop.crossovers = new_pop.crossovers + (crossover and 1 or 0)
      
      -- mutation
      local offspring1, mut1 = Mutate(offspring1)
      local offspring2, mut2 = Mutate(offspring2)
      new_pop.mutations = new_pop.mutations + mut1 + mut2
      
      -- store ancestry tree
      offspring1.parent1, offspring1.parent2 = idx1, idx2
      offspring2.parent1, offspring2.parent2 = idx1, idx2
      table.insert(new_pop, offspring1)
      table.insert(new_pop, offspring2)
    end
    
    EvaluatePopulation(new_pop)
    if FITNESS_SCALING then
      ScalePopulation(new_pop, FITNESS_SCALING)
    end
    PrintPopulation(pop, gen, new_pop)
    pop = new_pop
    
    if gen % GRAPH_GEN_INTERVAL == 0 then
      table.insert(graphs.funcs["Max"], {x = gen, y = PLOT_FUNCTION(pop.max_objective)})
      table.insert(graphs.funcs["Min"], {x = gen, y = PLOT_FUNCTION(pop.min_objective)})
      table.insert(graphs.funcs["Avg"], {x = gen, y = PLOT_FUNCTION(pop.avg_objective)})
    end
  end
  
  local time = os.clock() - start_clock
  
  local bmp = Bitmap.new(IMAGE_WIDTH, IMAGE_HEIGHT)
  bmp:Fill(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT, {0, 0, 0})
  DrawGraphs(bmp, graphs, nil, "int x")
  local text = string.format("Time (Lua 5.3): %ss", time)
  local tw, th = bmp:MeasureText(text)
  bmp:DrawText(IMAGE_WIDTH - tw - 5, 5, text, {128, 128, 128})
  text = string.format("Final %s: %.2f", MINIMIZATION and "Sqrt(Min)" or "Max", MINIMIZATION and math.sqrt(pop.min_objective) or pop.max_objective)
  tw, th = bmp:MeasureText(text)
  bmp:DrawText((IMAGE_WIDTH - tw) // 2, 5, text, MINIMIZATION and {0, 0, 255} or {255, 0, 0})
  bmp:WriteBMP(string.format("GA/SGA_%s_gens%d_pop%d%s.bmp", IMAGE_NAME, max_generations, POPULATION_SIZE, FITNESS_SCALING and string.format("_FS%.2f", FITNESS_SCALING) or ""))
end

RunSGA()