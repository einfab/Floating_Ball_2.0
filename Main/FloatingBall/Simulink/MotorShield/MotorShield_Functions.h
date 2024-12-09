/* Copyright 2023 The MathWorks, Inc. */
#ifndef EXAMPLE_H
#define EXAMPLE_H
#if !( defined(MATLAB_MEX_FILE) || defined(RSIM_PARAMETER_LOADING) ||  defined(RSIM_WITH_SL_SOLVER))
#include "rtwtypes.h"
#ifdef __cplusplus
extern "C" {
    #endif
    void stepFunctionMotorShield_Functions(uint8_T Speed,int size_vector_a);
    void setupFunctionMotorShield_Functions();
    #ifdef __cplusplus
}
#endif
#else
#define loop(void) (0)
#define setup(void) (0)
#endif
#endif