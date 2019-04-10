const snarkjs = require("snarkjs");
const compiler = require("circom");
const {smt, eddsa} = require("circomlib");
const fs = require('fs');

const bigInt = snarkjs.bigInt;

async function main(){
  //const cirDef = await compiler('./circuit.circom');
  const cirDef = JSON.parse(fs.readFileSync('circuit.json', "utf8")); 

  circuit = new snarkjs.Circuit(cirDef);

  console.log("NConstrains SMTVerifier: " + circuit.nConstraints);

  const msg = bigInt(123457);

  const prvKey = Buffer.from("0001020304050607080900010203040506070809000102030405060708090001", "hex");

  const pubKey = eddsa.prv2pub(prvKey);

  const signature = eddsa.signMiMC(prvKey, msg);

  tree = await smt.newMemEmptyTrie();
  await tree.insert(7,77);
  await tree.insert(8,88);
  await tree.insert(32,3232);
  await tree.insert(pubKey[0],pubKey[1])

  const key = pubKey[0];
  console.log(key);
  const res = await tree.find(key);

  let siblings = res.siblings;
  while (siblings.length<4) siblings.push(bigInt(0));

  const w = circuit.calculateWitness({
      enabled: 1,
      M: msg,
      root: tree.root,
      siblings: siblings,
      salt: key,
      S: signature.S,
      R8x: signature.R8[0],
      R8y: signature.R8[1],
      Ax: key,
      Ay: res.foundValue
  });

  //const setup = snarkjs.original.setup(circuit))
  
  const vk_proof = snarkjs.unstringifyBigInts(JSON.parse(fs.readFileSync("proving_key.json", "utf8")));
  const vk_verifier = snarkjs.unstringifyBigInts(JSON.parse(fs.readFileSync("verification_key.json", "utf8")));

  //fs.writeFileSync("myCircuit.vk_proof", JSON.stringify(snarkjs.stringifyBigInts(setup.vk_proof)), "utf8");
  //fs.writeFileSync("myCircuit.vk_verifier", JSON.stringify(snarkjs.stringifyBigInts(setup.vk_verifier)), "utf8");

  const proof = snarkjs.original.genProof(vk_proof,w)

  fs.writeFileSync("proof.json", JSON.stringify(snarkjs.stringifyBigInts(proof.proof)), "utf8");
  fs.writeFileSync("public.json", JSON.stringify(snarkjs.stringifyBigInts(proof.publicSignals)), "utf8");



  return snarkjs.original.isValid(vk_verifier,proof.proof,proof.publicSignals)
  //return 0
}

main().then(console.log).catch(console.log)
