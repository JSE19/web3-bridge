# Understanding Solidity Data Locations: Structs, Mappings, and Arrays

In Solidity, managing gas costs and contract logic depends heavily on understanding where data is stored. This guide shows us where `storage`, `memory`, and `calldata`.

---

## 1. Where are they stored?

Solidity offers three primary data locations. The choice depends on whether you need the data to persist and who is paying the gas for that persistence.

### **Storage**

* **Location:** On the blockchain (permanent).
* **Behavior:** Like a computer's hard drive. It persists between function calls and transactions.
* **Cost:** High gas cost for writes.
* **Types:** State variables defined outside functions are **always** in storage by default.

### **Memory**

* **Location:** RAM (temporary).
* **Behavior:** Exists only during the execution of a function. Once the function finishes, the data is wiped.
* **Cost:** Much cheaper than storage.
* **Types:** Usually used for intermediate calculations or returning values.

### **Calldata**

* **Location:** A special, non-modifiable area containing function arguments.
* **Behavior:** Read-only and temporary. It is the cheapest way to pass large arrays or structs into a function.

---

## 2. Why don't Mappings need a location specifier?

Mappings are unique because of how they are implemented. They use a Keccak-256 hash of the key to find the location of the value. Because they require a persistent "key-value" lookup table, **mappings can only exist in `storage`.**

> **Note:** You cannot create a mapping inside a function as a local `memory` variable because there is no way to "allocate" a mapping in RAM. It must be a state variable or a reference to a state variable.

---

## 3. Behavioral Differences During Execution

The way these types behave depends entirely on how you assign them.

### **Structs and Arrays**

When you move these types between locations, the EVM performs different operations:

| Operation | Effect | Behavior |
| --- | --- | --- |
| **Storage to Local Storage** | **Reference** | Creating a pointer. Changing the local variable changes the state variable. |
| **Storage to Memory** | **Copy** | A snapshot is taken. Changes to the memory variable **do not** affect the blockchain state. |
| **Memory to Memory** | **Reference** | For reference types, it points to the same memory slot. |
| **Memory to Storage** | **Copy** | Updates the state variable on the blockchain (Expensive). |

### **Mappings**

* **Invocations:** Mappings are never copied. When you "call" a mapping, you are strictly performing a lookup.
* **Initialization:** If you access a key that hasn't been set, the mapping returns the "zero-value" for that type (e.g., `0` for `uint`, `false` for `bool`).

---

## Quick Reference Summary

* **Arrays:** Can be `storage`, `memory`, or `calldata`.
* **Structs:** Like arrays, they require a location specifier when used in functions.
* **Mappings:** No location specifier is needed because they have no home other than `storage`.