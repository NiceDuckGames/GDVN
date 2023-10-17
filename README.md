# GDVN
 Godot Variant Notation

GDVN is a notation built on top of JSON that handles encoding Godot Variant data types into parsable strings.

# Syntax

Godot Variants are formatted into Strings using their constructor syntax. For example:

```json
{
    "test_vector": "Vector2(123, 456)"
}
```

The encoded strings are then parsed back into Variants using Godot's Expression class, which is able to parse Variant constructors.

# Usage

The singleton is used exactly the same as Godot's built-in JSON class.

#### `String stringify(data: Variant, indent: String = "    ", sort_keys: bool = false, full_precision: bool = false)`
Converts `data` into a String formatted using the Variant's constructor syntax. If `data` is a Dictionary or Array, this is done recursively for every key:value pair or element, then the data is converted to a String in JSON format.

#### `Variant parse_string(data: String)`
Converts a String encoded with `stringify()` back into a Variant.

#### `Variant stringify_variants(data: Variant)`
Converts a Variant into a String formatted using the Variant's constructor syntax. If `data` is a Dictionary or Array, this is done recursively for every key:value pair or element. Does not encode data into JSON format.

#### `Variant parse_variant_strings(data: Variant)`
Converts a constructor syntax String back into a Variant. If `data` is a Dictionary or Array, this is done recursively for every key:value pair or element. Does not encode data into JSON format.

#### `Variant string_to_variant(data: String)`
Converts a single constructor syntax String into a Variant.
