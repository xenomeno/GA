function string.format_table(fmt_str, params_tbl, num_fmt)
  local function repl_func(param)
    local value = params_tbl[param]
    if value ~= nil then
      if type(value) == "bool" then
        return tostring(value)
      elseif type(value) == "number" then
        local value_fmt = num_fmt and num_fmt[param]
        return value_fmt and string.format(value_fmt, value) or tostring(value)
      else
        return tostring(value)
      end
    else
      return string.format("<%s - invalid param!>", param)
    end
  end

  local str = string.gsub(fmt_str, "<([%w_]+)>", repl_func)
  
  return str
end
    
GA_CompareSets =
{
  F1_RouletteWheel_vs_StochasticRemainder =
  {
    test_name = "De Jong F1: Roulette Wheel vs Stochastic Remainder Selection Without Replacement",
    plots =
    {
      { image = "DeJongF1_RW_vs_SRSWR_Interim", graph = "Interim" },
      { image = "DeJongF1_RW_vs_SRSWR_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> RWS=<roulette_wheel>",
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = false, color = {64, 0, 0} },
    { size = 60, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = false, color = {128, 0, 0} },
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = false, color = {255, 0, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, fitness_scaling = false, color = {0, 64, 0} },
    { size = 60, minimization = "DeJongF1", roulette_wheel = true, fitness_scaling = false, color = {0, 128, 0} },
    { size = 100, minimization = "DeJongF1", roulette_wheel = true, fitness_scaling = false, color = {0, 255, 0} },
  },
  F5_RouletteWheel_vs_StochasticRemainder =
  {
    test_name = "De Jong F5: Roulette Wheel vs Stochastic Remainder Selection Without Replacement",
    plots =
    {
      { image = "DeJongF5_RW_vs_SRSWR_Interim", graph = "Interim" },
      { image = "DeJongF5_RW_vs_SRSWR_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> RWS=<roulette_wheel>",
    runs = 20,
    init_depression = 400.0,
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = false, color = {64, 0, 0} },
    { size = 60, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = false, color = {128, 0, 0} },
    { size = 100, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = false, color = {255, 0, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = true, fitness_scaling = false, color = {0, 64, 0} },
    { size = 60, minimization = "DeJongF5", roulette_wheel = true, fitness_scaling = false, color = {0, 128, 0} },
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, fitness_scaling = false, color = {0, 255, 0} },
  },
  Max_RouletteWheel_vs_StochasticRemainder =
  {
    test_name = "Max x^10: Roulette Wheel vs Stochastic Remainder Selection Without Replacement",
    plots =
    {
      { image = "MaxPow10_RW_vs_SRSWR_Interim", graph = "Interim" },
      { image = "MaxPow10_RW_vs_SRSWR_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> RWS=<roulette_wheel>",
    runs = 20,
    init_depression = 0.05,
    { size = 30, minimization = false, roulette_wheel = false, fitness_scaling = false, color = {64, 0, 0} },
    { size = 60, minimization = false, roulette_wheel = false, fitness_scaling = false, color = {128, 0, 0} },
    { size = 100, minimization = false, roulette_wheel = false, fitness_scaling = false, color = {255, 0, 0} },
    { size = 30, minimization = false, roulette_wheel = true, fitness_scaling = false, color = {0, 64, 0} },
    { size = 60, minimization = false, roulette_wheel = true, fitness_scaling = false, color = {0, 128, 0} },
    { size = 100, minimization = false, roulette_wheel = true, fitness_scaling = false, color = {0, 255, 0} },
  },
  Max_FitnessScale =
  {
    test_name = "Max x^10: Fitness Scale n=30",
    plots =
    {
      { image = "MaxPow10_FS_Interim", graph = "Interim" },
      { image = "MaxPow10_FS_Ultimate", graph = "Ultimate" },
    },
    func_name = "FS=<fitness_scaling>",
    num_fmt = { ["fitness_scaling"] = "%.2f" },
    runs = 20,
    { size = 30, minimization = false, roulette_wheel = false, fitness_scaling = false, color = {255, 255, 255} },
    { size = 30, minimization = false, roulette_wheel = false, fitness_scaling = 4.00, color = {128, 0, 128} },
    { size = 30, minimization = false, roulette_wheel = false, fitness_scaling = 2.00, color = {255, 255, 0} },
    { size = 30, minimization = false, roulette_wheel = false, fitness_scaling = 3.00, color = {0, 64, 64} },
    { size = 30, minimization = false, roulette_wheel = false, fitness_scaling = 5.00, color = {255, 128, 0} },
    { size = 30, minimization = false, roulette_wheel = false, fitness_scaling = 6.00, color = {0, 255, 192} },
  },
  F1_FitnessScale =
  {
    test_name = "De Jong F1: Fitness Scale n=30",
    plots =
    {
      { image = "F1_FS_Interim", graph = "Interim" },
      { image = "F1_FS_Ultimate", graph = "Ultimate" },
    },
    func_name = "FS=<fitness_scaling>",
    num_fmt = { ["fitness_scaling"] = "%.3f" },
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, fitness_scaling = false, color = {255, 255, 255}},
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, fitness_scaling = 2.00, color = {128, 0, 128} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, fitness_scaling = 3.00, color = {255, 255, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, fitness_scaling = 4.00, color = {0, 64, 64} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, fitness_scaling = 5.00, color = {255, 128, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, fitness_scaling = 6.00, color = {0, 255, 192} },
  },
  F5_FitnessScale =
  {
    test_name = "De Jong F5: Fitness Scale n=30",
    plots =
    {
      { image = "F5_FS_Interim", graph = "Interim" },
      { image = "F5_FS_Ultimate", graph = "Ultimate" },
    },
    func_name = "FS=<fitness_scaling>",
    num_fmt = { ["fitness_scaling"] = "%.3f" },
    runs = 20,
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = false, color = {255, 255, 255} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 2.00, color = {128, 0, 128} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 4.00, color = {255, 255, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 6.00, color = {0, 64, 64}  },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 8.00, color = {255, 128, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 10.00, color = {0, 255, 192} },
  },
  F1_FitnessScale_Sigma =
  {
    test_name = "De Jong F1: Sigma Trunc n=100 FitnessScale=2.0",
    plots =
    {
      { image = "F1_SigmaTrunc_Interim", graph = "Interim" },
      { image = "F1_SigmaTrunc_Ultimate", graph = "Ultimate" },
    },
    func_name = "Sigma=<sigma_trunc>",
    num_fmt = { ["sigma_trunc"] = "%.1f" },
    runs = 20,
    init_depression = 40.0,
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 1.0, color = {255, 255, 255} },
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 1.5, color = {128, 0, 128} },
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 2.0, color = {255, 255, 0} },
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 2.5, color = {0, 64, 64}  },
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 3.0, color = {255, 128, 0} },
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 4.0, color = {0, 255, 192} },
  },
  F5_FitnessScale_Sigma =
  {
    test_name = "De Jong F5: Sigma Trunc n=100 FitnessScale=4.0 Roulette Wheel Selection",
    plots =
    {
      { image = "F5_SigmaTrunc_Interim", graph = "Interim" },
      { image = "F5_SigmaTrunc_Ultimate", graph = "Ultimate" },
    },
    func_name = "Sigma=<sigma_trunc>",
    num_fmt = { ["sigma_trunc"] = "%.1f" },
    runs = 20,
    init_depression = 400.0,
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, fitness_scaling = 4.00, sigma_trunc = 1.0, color = {255, 255, 255} },
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, fitness_scaling = 4.00, sigma_trunc = 1.5, color = {128, 0, 128} },
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, fitness_scaling = 4.00, sigma_trunc = 2.0, color = {255, 255, 0} },
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, fitness_scaling = 4.00, sigma_trunc = 2.5, color = {0, 64, 64}  },
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, fitness_scaling = 4.00, sigma_trunc = 3.0, color = {255, 128, 0} },
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, fitness_scaling = 4.00, sigma_trunc = 4.0, color = {0, 255, 192} },
  },
  Max_FitnessScale_Sigma =
  {
    test_name = "Max x^10: Sigma Trunc n=100 FitnessScale=2.0",
    plots =
    {
      { image = "Max_SigmaTrunc_Interim", graph = "Interim" },
      { image = "Max_SigmaTrunc_Ultimate", graph = "Ultimate" },
    },
    func_name = "Sigma=<sigma_trunc>",
    num_fmt = { ["sigma_trunc"] = "%.1f" },
    runs = 20,
    init_depression = 0.05,
    { size = 100, minimization = false, roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 1.0, color = {255, 255, 255} },
    { size = 100, minimization = false, roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 1.5, color = {128, 0, 128} },
    { size = 100, minimization = false, roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 2.0, color = {255, 255, 0} },
    { size = 100, minimization = false, roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 2.5, color = {0, 64, 64}  },
    { size = 100, minimization = false, roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 3.0, color = {255, 128, 0} },
    { size = 100, minimization = false, roulette_wheel = false, fitness_scaling = 2.00, sigma_trunc = 4.0, color = {0, 255, 192} },
  },
  F5_GenGap =
  {
    test_name = "De Jong F5: Generation Gap vs No Gap(1.0)",
    plots =
    {
      { image = "F5_GGap_Interim", graph = "Interim" },
      { image = "F5_GGap_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> GGap=<generation_gap>",
    num_fmt = { ["generation_gap"] = "%.2f" },
    runs = 20,
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 1.0, color = {64, 0, 0} },
    { size = 60, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 1.0, color = {128, 0, 0} },
    { size = 100, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 1.0, color = {255, 0, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 0.1, color = {0, 64, 0} },
    { size = 60, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 0.1, color = {0, 128, 0} },
    { size = 100, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 0.1, color = {0, 255, 0} },
  },
  F5_GenGap_Pop30 =
  {
    test_name = "De Jong F5: Generation Gap n=30",
    plots =
    {
      { image = "F5_GGapPop30_Interim", graph = "Interim" },
      { image = "F5_GGapPop30_Ultimate", graph = "Ultimate" },
    },
    func_name = "GenGap=<generation_gap>",
    num_fmt = { ["generation_gap"] = "%.2f" },
    runs = 20,
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 0.8, color = {0, 255, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 0.6, color = {0, 0, 255} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 0.5, color = {255, 255, 255} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 0.4, color = {255, 255, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 0.9, color = {0, 255, 255} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 0.1, color = {255, 0, 255} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, generation_gap = 1.0, color = {255, 0, 0} },
  },
  F5_GenGap_Pop30_CF =
  {
    test_name = "De Jong F5: GenGap=0.1 n=30 Crowding Factor",
    plots =
    {
      { image = "F5_GGapPop30_CF_Interim", graph = "Interim" },
      { image = "F5_GGapPop30_CF_Ultimate", graph = "Ultimate" },
    },
    func_name = "CF=<crowding_factor>",
    num_fmt = { ["crowding_factor"] = "% 2d" },
    runs = 20,
    { size = 30, minimization = "DeJongF5", crowding_factor = 1, generation_gap = 0.1, color = {0, 255, 0} },
    { size = 30, minimization = "DeJongF5", crowding_factor = 2, generation_gap = 0.1, color = {0, 0, 255} },
    { size = 30, minimization = "DeJongF5", crowding_factor = 3, generation_gap = 0.1, color = {255, 255, 255} },
    { size = 30, minimization = "DeJongF5", crowding_factor = 4, generation_gap = 0.1, color = {255, 255, 0} },
    { size = 30, minimization = "DeJongF5", crowding_factor = 5, generation_gap = 0.1, color = {0, 255, 255} },
    { size = 30, minimization = "DeJongF5", crowding_factor = 6, generation_gap = 0.1, color = {255, 0, 255} },
    { size = 30, minimization = "DeJongF5", crowding_factor = 7, generation_gap = 0.1, color = {255, 0, 0} },
  },
  Max_Dev =
  {
    test_name = "Max x^10 Deviation: Roulette Wheel vs Stochastic Remainder Selection Without Replacement",
    plots =
    {
      { image = "MaxPow10_Dev", graph = "Dev" },
    },
    func_name = "n=<size> RW=<roulette_wheel>",
    runs = 20,
    { size = 30, minimization = false, roulette_wheel = false, fitness_scaling = false, color = {64, 0, 0} },
    { size = 60, minimization = false, roulette_wheel = false, fitness_scaling = false, color = {128, 0, 0} },
    { size = 100, minimization = false, roulette_wheel = false, fitness_scaling = false, color = {255, 0, 0} },
    { size = 30, minimization = false, roulette_wheel = true, fitness_scaling = false, color = {0, 64, 0} },
    { size = 60, minimization = false, roulette_wheel = true, fitness_scaling = false, color = {0, 128, 0} },
    { size = 100, minimization = false, roulette_wheel = true, fitness_scaling = false, color = {0, 255, 0} },
  },
  F1_Rank_vs_RouletteWheel =
  {
    test_name = "De Jong F1: Rank Selection vs Roulette Wheel Selection",
    plots =
    {
      { image = "DeJongF1_RS_vs_RW_Interim", graph = "Interim" },
      { image = "DeJongF1_RS_vs_RW_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> <name>",
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, rank_selection = true, color = {64, 0, 0}, name = "RS" },
    { size = 60, minimization = "DeJongF1", roulette_wheel = true, rank_selection = true, color = {128, 0, 0}, name = "RS" },
    { size = 100, minimization = "DeJongF1", roulette_wheel = true, rank_selection = true, color = {255, 0, 0}, name = "RS" },
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, rank_selection = false, color = {0, 64, 0}, name = "RW" },
    { size = 60, minimization = "DeJongF1", roulette_wheel = true, rank_selection = false, color = {0, 128, 0}, name = "RW" },
    { size = 100, minimization = "DeJongF1", roulette_wheel = true, rank_selection = false, color = {0, 255, 0}, name = "RW" },
  },
  F5_Rank_vs_RouletteWheel =
  {
    test_name = "De Jong F5: Rank Selection vs Roulette Wheel Selection",
    plots =
    {
      { image = "DeJongF5_RS_vs_RW_Interim", graph = "Interim" },
      { image = "DeJongF5_RS_vs_RW_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> <name>",
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF5", roulette_wheel = true, rank_selection = true, color = {64, 0, 0}, name = "RS" },
    { size = 60, minimization = "DeJongF5", roulette_wheel = true, rank_selection = true, color = {128, 0, 0}, name = "RS" },
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, rank_selection = true, color = {255, 0, 0}, name = "RS" },
    { size = 30, minimization = "DeJongF5", roulette_wheel = true, rank_selection = false, color = {0, 64, 0}, name = "RW" },
    { size = 60, minimization = "DeJongF5", roulette_wheel = true, rank_selection = false, color = {0, 128, 0}, name = "RW" },
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, rank_selection = false, color = {0, 255, 0}, name = "RW" },
  },
  Max_Rank_vs_RouletteWheel =
  {
    test_name = "Max x^10: Rank Selection vs Roulette Wheel Selection",
    plots =
    {
      { image = "MaxPow10_RS_vs_RW_Interim", graph = "Interim" },
      { image = "MaxPow10_RS_vs_RW_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> <name>",
    runs = 20,
    init_depression = 0.05,
    { size = 30, minimization = false, roulette_wheel = true, rank_selection = true, color = {64, 0, 0}, name = "RS" },
    { size = 60, minimization = false, roulette_wheel = true, rank_selection = true, color = {128, 0, 0}, name = "RS" },
    { size = 100, minimization = false, roulette_wheel = true, rank_selection = true, color = {255, 0, 0}, name = "RS" },
    { size = 30, minimization = false, roulette_wheel = true, rank_selection = false, color = {0, 64, 0}, name = "RW" },
    { size = 60, minimization = false, roulette_wheel = true, rank_selection = false, color = {0, 128, 0}, name = "RW" },
    { size = 100, minimization = false, roulette_wheel = true, rank_selection = false, color = {0, 255, 0}, name = "RW" },
  },
  F1_Rank_vs_StochasticRemainder =
  {
    test_name = "De Jong F1: Rank Selection vs Stochastic Remainder Without Replacement Selection",
    plots =
    {
      { image = "DeJongF1_RS_vs_SRWR_Interim", graph = "Interim" },
      { image = "DeJongF1_RS_vs_SRWR_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> <name>",
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, rank_selection = 5, color = {64, 0, 0}, name = "RS" },
    { size = 60, minimization = "DeJongF1", roulette_wheel = false, rank_selection = 5, color = {128, 0, 0}, name = "RS" },
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, rank_selection = 5, color = {255, 0, 0}, name = "RS" },
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, rank_selection = 5, color = {0, 64, 0}, name = "SRWR" },
    { size = 60, minimization = "DeJongF1", roulette_wheel = false, rank_selection = 5, color = {0, 128, 0}, name = "SRWR" },
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, rank_selection = 5, color = {0, 255, 0}, name = "SRWR" },
  },
  F5_Rank_vs_StochasticRemainder =
  {
    test_name = "De Jong F5: Rank Selection vs Stochastic Remainder Without Replacement Selection",
    plots =
    {
      { image = "DeJongF5_RS_vs_SRWR_Interim", graph = "Interim" },
      { image = "DeJongF5_RS_vs_SRWR_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> <name>",
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, rank_selection = 5, color = {64, 0, 0}, name = "RS" },
    { size = 60, minimization = "DeJongF5", roulette_wheel = false, rank_selection = 5, color = {128, 0, 0}, name = "RS" },
    { size = 100, minimization = "DeJongF5", roulette_wheel = false, rank_selection = 5, color = {255, 0, 0}, name = "RS" },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, rank_selection = 5, color = {0, 64, 0}, name = "SRWR" },
    { size = 60, minimization = "DeJongF5", roulette_wheel = false, rank_selection = 5, color = {0, 128, 0}, name = "SRWR" },
    { size = 100, minimization = "DeJongF5", roulette_wheel = false, rank_selection = 5, color = {0, 255, 0}, name = "SRWR" },
  },
  F1_CrossoverPoints =
  {
    test_name = "De Jong F1: Crossover Points",
    plots =
    {
      { image = "DeJongF1_CP_Interim", graph = "Interim" },
      { image = "DeJongF1_CP_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> CP=<crossover_points>",
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, crossover_points = 1, color = {64, 0, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, crossover_points = 2, color = {128, 0, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, crossover_points = 3, color = {255, 0, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, crossover_points = 4, color = {0, 64, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, crossover_points = 7, color = {0, 128, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, crossover_points = 8, color = {0, 255, 0} },
  },
  F5_CrossoverPoints =
  {
    test_name = "De Jong F5: Crossover Points",
    plots =
    {
      { image = "DeJongF5_CP_Interim", graph = "Interim" },
      { image = "DeJongF5_CP_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> CP=<crossover_points>",
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, crossover_points = 1, color = {64, 0, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, crossover_points = 2, color = {128, 0, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, crossover_points = 3, color = {255, 0, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, crossover_points = 4, color = {0, 64, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, crossover_points = 7, color = {0, 128, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, crossover_points = 8, color = {0, 255, 0} },
  },
  Max_CrossoverPoints =
  {
    test_name = "Max x^10: Crossover Points",
    plots =
    {
      { image = "MaxPow10_CP_Interim", graph = "Interim" },
      { image = "MaxPow10_CP_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> CP=<crossover_points>",
    runs = 20,
    init_depression = 0.01,
    { size = 100, minimization = false, roulette_wheel = false, crossover_points = 1, color = {64, 0, 0} },
    { size = 100, minimization = false, roulette_wheel = false, crossover_points = 2, color = {128, 0, 0} },
    { size = 100, minimization = false, roulette_wheel = false, crossover_points = 3, color = {255, 0, 0} },
    { size = 100, minimization = false, roulette_wheel = false, crossover_points = 4, color = {0, 64, 0} },
    { size = 100, minimization = false, roulette_wheel = false, crossover_points = 7, color = {0, 128, 0} },
    { size = 100, minimization = false, roulette_wheel = false, crossover_points = 8, color = {0, 255, 0} },
  },
  F1_FitnessScale_vs_Sigma =
  {
    test_name = "De Jong F1: Sigma Trunc vs Fitness Scale",
    plots =
    {
      { image = "F1_FS_vs_SGT_Interim", graph = "Interim" },
      { image = "F1_FS_vs_SGT_Ultimate", graph = "Ultimate" },
    },
    func_name = "n<size> FS=<fitness_scaling> ST=<sigma_trunc>",
    num_fmt = { ["sigma_trunc"] = "%.1f", ["fitness_scaling"] = "%.1f" },
    runs = 20,
    init_depression = 40.0,
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = 1.5, color = {255, 255, 255} },
    { size = 60, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = 1.5, color = {128, 0, 128} },
    { size = 90, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = 1.5, color = {255, 255, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = false, color = {0, 64, 64}  },
    { size = 60, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 1.5, sigma_trunc = false, color = {255, 128, 0} },
    { size = 90, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 1.7, sigma_trunc = false, color = {0, 255, 192} },
  },
  F5_FitnessScale_vs_Sigma =
  {
    test_name = "De Jong F5: Sigma Trunc vs Fitness Scale",
    plots =
    {
      { image = "F5_FS_vs_SGT_Interim", graph = "Interim" },
      { image = "F5_FS_vs_SGT_Ultimate", graph = "Ultimate" },
    },
    func_name = "n<size> FS=<fitness_scaling> ST=<sigma_trunc>",
    num_fmt = { ["sigma_trunc"] = "%.1f", ["fitness_scaling"] = "%.1f" },
    runs = 20,
    init_depression = 40.0,
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = 1.5, color = {255, 255, 255} },
    { size = 60, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = 1.5, color = {128, 0, 128} },
    { size = 90, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = 1.5, color = {255, 255, 0} },
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = false, color = {0, 64, 64}  },
    { size = 60, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 1.5, sigma_trunc = false, color = {255, 128, 0} },
    { size = 90, minimization = "DeJongF5", roulette_wheel = false, fitness_scaling = 1.7, sigma_trunc = false, color = {0, 255, 192} },
  },
  Max_FitnessScale_vs_Sigma =
  {
    test_name = "Max x^10: Sigma Trunc vs Fitness Scale",
    plots =
    {
      { image = "Max_FS_vs_SGT_Interim", graph = "Interim" },
      { image = "Max_FS_vs_SGT_Ultimate", graph = "Ultimate" },
    },
    func_name = "n<size> FS=<fitness_scaling> ST=<sigma_trunc>",
    num_fmt = { ["sigma_trunc"] = "%.1f", ["fitness_scaling"] = "%.1f" },
    runs = 20,
    init_depression = 40.0,
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = 1.5, color = {255, 255, 255} },
    { size = 60, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = 1.5, color = {128, 0, 128} },
    { size = 90, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = 1.5, color = {255, 255, 0} },
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 2.0, sigma_trunc = false, color = {0, 64, 64}  },
    { size = 60, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 1.5, sigma_trunc = false, color = {255, 128, 0} },
    { size = 90, minimization = "DeJongF1", roulette_wheel = false, fitness_scaling = 1.7, sigma_trunc = false, color = {0, 255, 192} },
  },
  F1_Ranking_RouletteWheel_vs_StochasticRemainder =
  {
    test_name = "De Jong F1: Ranking compare: Roulette Wheel vs Stochastic Remainder Without Replacement",
    plots =
    {
      { image = "DeJongF1_Rank_RW_vs_SRWR_Interim", graph = "Interim" },
      { image = "DeJongF1_Rank_RW_vs_SRWR_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> <name>",
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF1", roulette_wheel = false, rank_selection = 5, color = {64, 0, 0}, name = "SRWR+MAX=5" },
    { size = 60, minimization = "DeJongF1", roulette_wheel = false, rank_selection = 5, color = {128, 0, 0}, name = "SRWR+MAX=5" },
    { size = 100, minimization = "DeJongF1", roulette_wheel = false, rank_selection = 5, color = {255, 0, 0}, name = "SRWR+MAX=5" },
    { size = 30, minimization = "DeJongF1", roulette_wheel = true, rank_selection = true, color = {0, 64, 0}, name = "RW+RS" },
    { size = 60, minimization = "DeJongF1", roulette_wheel = true, rank_selection = true, color = {0, 128, 0}, name = "RW+RS" },
    { size = 100, minimization = "DeJongF1", roulette_wheel = true, rank_selection = true, color = {0, 255, 0}, name = "RW+RS" },
  },
  F5_Ranking_RouletteWheel_vs_StochasticRemainder =
  {
    test_name = "De Jong F5: Ranking compare: Roulette Wheel vs Stochastic Remainder Without Replacement",
    plots =
    {
      { image = "DeJongF5_Rank_RW_vs_SRWR_Interim", graph = "Interim" },
      { image = "DeJongF5_Rank_RW_vs_SRWR_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> <name>",
    runs = 20,
    init_depression = 60.0,
    { size = 30, minimization = "DeJongF5", roulette_wheel = false, rank_selection = 5, color = {64, 0, 0}, name = "SRWR+MAX=5" },
    { size = 60, minimization = "DeJongF5", roulette_wheel = false, rank_selection = 5, color = {128, 0, 0}, name = "SRWR+MAX=5" },
    { size = 100, minimization = "DeJongF5", roulette_wheel = false, rank_selection = 5, color = {255, 0, 0}, name = "SRWR+MAX=5" },
    { size = 30, minimization = "DeJongF5", roulette_wheel = true, rank_selection = true, color = {0, 64, 0}, name = "RW+RS" },
    { size = 60, minimization = "DeJongF5", roulette_wheel = true, rank_selection = true, color = {0, 128, 0}, name = "RW+RS" },
    { size = 100, minimization = "DeJongF5", roulette_wheel = true, rank_selection = true, color = {0, 255, 0}, name = "RW+RS" },
  },
  Max_Ranking_RouletteWheel_vs_StochasticRemainder =
  {
    test_name = "Max x^10: Ranking compare: Roulette Wheel vs Stochastic Remainder Without Replacement",
    plots =
    {
      { image = "Max_Rank_RW_vs_SRWR_Interim", graph = "Interim" },
      { image = "Max_Rank_RW_vs_SRWR_Ultimate", graph = "Ultimate" },
    },
    func_name = "n=<size> <name>",
    runs = 20,
    init_depression = 0.01,
    { size = 30, minimization = false, roulette_wheel = false, rank_selection = 25, color = {64, 0, 0}, name = "SRWR+MAX=25" },
    { size = 60, minimization = false, roulette_wheel = false, rank_selection = 25, color = {128, 0, 0}, name = "SRWR+MAX=25" },
    { size = 100, minimization = false, roulette_wheel = false, rank_selection = 25, color = {255, 0, 0}, name = "SRWR+MAX=25" },
    { size = 30, minimization =false, roulette_wheel = true, rank_selection = true, color = {0, 64, 0}, name = "RW+RS" },
    { size = 60, minimization = false, roulette_wheel = true, rank_selection = true, color = {0, 128, 0}, name = "RW+RS" },
    { size = 100, minimization = false, roulette_wheel = true, rank_selection = true, color = {0, 255, 0}, name = "RW+RS" },
  },
}