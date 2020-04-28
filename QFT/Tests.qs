﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains testing harness for all tasks.
// You should not modify anything in this file.
// The tasks themselves can be found in Tasks.qs file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.QFT {
    
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Bitwise;


    operation ArrayWrapperControlledOperation (op : (Qubit => Unit is Adj+Ctl), register : Qubit[]) : Unit is Adj+Ctl {
        Controlled op([register[0]], register[1]);
    }

    operation T11_Test () : Unit {
        AssertOperationsEqualReferenced(2, ArrayWrapperControlledOperation(OneQubitQFT, _), 
                                           ArrayWrapperControlledOperation(OneQubitQFT_Reference, _));
    }


    // ------------------------------------------------------
    operation T12_Test () : Unit {
        // several hardcoded tests for small values of k
        // k = 0: α |0⟩ + β · exp(2πi) |1⟩ = α |0⟩ + β |1⟩ - identity
        AssertOperationsEqualReferenced(2, ArrayWrapperControlledOperation(Rotation(_, 0), _), 
                                           ArrayWrapperControlledOperation(I, _));

        // k = 1: α |0⟩ + β · exp(2πi/2) |1⟩ = α |0⟩ - β |1⟩ - Z
        AssertOperationsEqualReferenced(2, ArrayWrapperControlledOperation(Rotation(_, 1), _), 
                                           ArrayWrapperControlledOperation(Z, _));

        // k = 2: α |0⟩ + β · exp(2πi/4) |1⟩ = α |0⟩ + iβ |1⟩ - S
        AssertOperationsEqualReferenced(2, ArrayWrapperControlledOperation(Rotation(_, 2), _), 
                                           ArrayWrapperControlledOperation(S, _));

        // k = 3: α |0⟩ + β · exp(2πi/8) |1⟩ - T
        AssertOperationsEqualReferenced(2, ArrayWrapperControlledOperation(Rotation(_, 3), _), 
                                           ArrayWrapperControlledOperation(T, _));

        // general case
        for (k in 4 .. 10) {
            AssertOperationsEqualReferenced(2, ArrayWrapperControlledOperation(Rotation(_, k), _), 
                                               ArrayWrapperControlledOperation(Rotation_Reference(_, k), _));
        }
    }


    // ------------------------------------------------------
    function IntAsIntArray (j : Int, nBits : Int) : Int[] {
        mutable bits = new Int[nBits];
        for (ind in 0 .. nBits - 1) {
            set bits w/= ind <- ((j &&& (1 <<< (nBits - 1 - ind))) > 0 ? 1 | 0);
        }
        return bits;
    }


    operation T13_Test () : Unit {
        for (n in 1 .. 5) {
            for (exponent in 0 .. (1 <<< n) - 1) {
                let bits = IntAsIntArray(exponent, n);
                Message($"{n}-bit {exponent} = {bits}");
                AssertOperationsEqualReferenced(2, ArrayWrapperControlledOperation(BinaryFractionClassical(_, bits), _), 
                                                   ArrayWrapperControlledOperation(BinaryFractionClassical_Reference(_, bits), _));

                // compare it to the single-rotation solution for good measure
                AssertOperationsEqualReferenced(2, ArrayWrapperControlledOperation(BinaryFractionClassical(_, bits), _), 
                                                   ArrayWrapperControlledOperation(BinaryFractionClassical_Alternative(_, bits), _));
            }
        }
    }


    // ------------------------------------------------------
    operation Task14InputWrapper (op : ((Qubit, Qubit[]) => Unit is Adj+Ctl), qs : Qubit[]) : Unit is Adj+Ctl {
        Controlled op([qs[0]], (qs[1], qs[2 ...]));
    }

    operation T14_Test () : Unit {
        for (n in 1 .. 5) {
            AssertOperationsEqualReferenced(n + 2, Task14InputWrapper(BinaryFractionQuantum, _), 
                                                   Task14InputWrapper(BinaryFractionQuantum_Reference, _));
        }
    }


    // ------------------------------------------------------
    operation T15_Test () : Unit {
        for (n in 1 .. 6) {
            AssertOperationsEqualReferenced(n, BinaryFractionQuantumInPlace, 
                                               BinaryFractionQuantumInPlace_Reference);
        }
    }


    // ------------------------------------------------------
    operation T16_Test () : Unit {
        for (n in 1 .. 6) {
            AssertOperationsEqualReferenced(n, ReverseRegister, 
                                               ReverseRegister_Reference);
            AssertOperationsEqualReferenced(n, ReverseRegister, 
                                               SwapReverseRegister);
        }
    }


    // ------------------------------------------------------
    operation HWrapper (register : Qubit[]) : Unit is Adj+Ctl {
        H(register[0]);
    }

    operation LibraryQFTWrapper (register : Qubit[]) : Unit is Adj+Ctl {
        QFT(BigEndian(register));
    }

    operation T17_Test () : Unit {
        AssertOperationsEqualReferenced(1, QuantumFourierTransform, HWrapper);

        for (n in 1 .. 5) {
            AssertOperationsEqualReferenced(n, QuantumFourierTransform, 
                                               QuantumFourierTransform_Reference);
            AssertOperationsEqualReferenced(n, QuantumFourierTransform, 
                                               LibraryQFTWrapper);
        }
    }


    // ------------------------------------------------------
    operation T18_Test () : Unit {
        AssertOperationsEqualReferenced(1, InverseQFT, HWrapper);

        for (n in 1 .. 5) {
            AssertOperationsEqualReferenced(n, InverseQFT, 
                                               InverseQFT_Reference);
            AssertOperationsEqualReferenced(n, InverseQFT, 
                                               Adjoint LibraryQFTWrapper);
        }
    }
}
