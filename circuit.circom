include "node_modules/circomlib/circuits/eddsamimc.circom";
include "node_modules/circomlib/circuits/smt/smtverifier.circom";
include "node_modules/circomlib/circuits/mimc.circom";

template unlayeredRequiredOnesigVerification(nLevels) {
    signal input enabled;

    signal input root;
    signal input M;

    signal output pubId;

    signal private input siblings[nLevels];

    signal private input Ax;
    signal private input Ay;
    signal private input salt;

    signal private input S;
    signal private input R8x;
    signal private input R8y;



    component verifier = SMTVerifier(nLevels);
    verifier.enabled <== enabled;
    verifier.root <== root;
    for (var i=0; i<nLevels; i++) verifier.siblings[i] <== siblings[i];
    verifier.oldKey <== 0;
    verifier.oldValue <== 0;
    verifier.isOld0 <== 0;
    verifier.key <== Ax;
    verifier.value <== Ay;
    verifier.fnc <== 0;


    component eddsa = EdDSAMiMCVerifier();
    eddsa.enabled <== enabled;
    eddsa.Ax <== Ax;
    eddsa.Ay <== Ay;
    eddsa.S <== S;
    eddsa.R8x <== R8x;
    eddsa.R8y <== R8y;
    eddsa.M <== M;


    component mimc = MultiMiMC7(3, 91);
    mimc.in[0] <== Ax;
    mimc.in[1] <== Ay;
    mimc.in[2] <== salt;

    pubId <== mimc.out;
}


component main = unlayeredRequiredOnesigVerification(4);
