#pragma once

#include <string>

#include "kernel.h"

class kernel_compiler
{
	CUmodule cuModule_;
	CUdevice cuDevice_;
	CUcontext cuContext_;

public:
	kernel_wrapper initialize_random, initialize_initial_state, simulate, window_average_small, final_states;

	kernel_compiler();
	~kernel_compiler();
	int compile_simulation(const std::string& code, bool discrete_time);
};
