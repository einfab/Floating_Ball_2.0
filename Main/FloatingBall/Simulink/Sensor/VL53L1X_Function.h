/* Copyright 2023 The MathWorks, Inc. */
#ifndef EXAMPLE_H
#define EXAMPLE_H
#if !( defined(MATLAB_MEX_FILE) || defined(RSIM_PARAMETER_LOADING) ||  defined(RSIM_WITH_SL_SOLVER))
#include "rtwtypes.h"
#ifdef __cplusplus
extern "C" {
    #endif
    void stepFunctionVL53L1X_Function(double * Distance,int size_vector_1,boolean_T * Error,int size_vector_2);
    void setupFunctionVL53L1X_Function();
    #ifdef __cplusplus
}
#endif
#else
#define loop(void) (0)
#define setup(void) (0)
#endif
#endif