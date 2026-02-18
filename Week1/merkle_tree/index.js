const crypto = require('crypto');

class MerkleTree {
  constructor(data) {
    this.leaves = data.map((d) => this.hash(d));
    this.tree = this.buildTree(this.leaves);
  }

  hash(data) {
    return crypto.createHash('sha256').update(data).digest('hex');
  }

  buildTree(leaves) {
    let tree = [leaves];
    while (leaves.length > 1) {
      let level = [];
      for (let i = 0; i < leaves.length; i += 2) {
        let left = leaves[i];
        let right = leaves[i + 1] || left; // duplicate if odd number of leaves
        level.push(this.hash(left + right));
      }
      tree.push(level);
      leaves = level;
    }
    return tree;
  }

  getRoot() {
    return this.tree[this.tree.length - 1][0];
  }
}

// Example usage
let data = ['a', 'b', 'c', 'd'];
let tree = new MerkleTree(data);
console.log('Merkle Root:', tree.getRoot());
