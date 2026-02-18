const crypto = window.crypto.subtle; // Use Node.js 'crypto' module if running in backend

class MerkleTree {
    constructor(data) {
        this.data = data;
        this.root = null;
    }

    // Helper: Simple SHA-256 hashing using the Web Crypto API
    async hash(message) {
        const msgUint8 = new TextEncoder().encode(message);
        const hashBuffer = await crypto.digest('SHA-256', msgUint8);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    }

    async generate() {
        if (this.data.length === 0) return null;

        // Step 1: Hash all leaf nodes (initial data)
        let nodes = await Promise.all(this.data.map(item => this.hash(item)));
        console.log("Leaf Hashes:", nodes);

        // Step 2: Keep hashing pairs until we reach the root
        while (nodes.length > 1) {
            // If odd number of nodes, duplicate the last one to create a pair
            if (nodes.length % 2 !== 0) {
                nodes.push(nodes[nodes.length - 1]);
            }

            let temporaryLevel = [];

            for (let i = 0; i < nodes.length; i += 2) {
                const left = nodes[i];
                const right = nodes[i + 1];
                const parentHash = await this.hash(left + right);
                
                console.log(`Hashing: [${left.slice(0,8)}...] + [${right.slice(0,8)}...] -> ${parentHash.slice(0,8)}...`);
                temporaryLevel.push(parentHash);
            }

            nodes = temporaryLevel;
        }

        this.root = nodes[0];
        return this.root;
    }
}

// --- Execution ---
const transactions = ['Alice pays Bob 10', 'Bob pays Charlie 5', 'Charlie pays Dave 2'];

const tree = new MerkleTree(transactions);

tree.generate().then(root => {
    console.log("-----------------------------------------");
    console.log("FINAL MERKLE ROOT:", root);
});