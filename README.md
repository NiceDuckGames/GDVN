![image](https://github.com/NiceDuckGames/GDVN/assets/69459114/cd67821d-8b3a-409f-93ed-c3715a1e251d)


# Godot Variant Notation

GDVN is a notation built on top of JSON that handles encoding Godot Variant data types to and from parsable strings.

# Syntax

Godot Variants are formatted into Strings using their constructor syntax. For example:

```json
{
    "test_vector": "Vector2(123, 456)",
    "Rect2(0.0, 0.0, 0.0, 0.0)" : "test_rect" 
}
```

This keeps the data readable, and is easily parsable by the engine using the Expression class.

# Usage

GDVN is used exactly the same as Godot's built-in JSON class. (See: [JSON Class Reference](https://docs.godotengine.org/en/stable/classes/class_json.html))

An [example script](https://github.com/NiceDuckGames/GDVN/blob/main/gdvn/example.gd) is provided that demonstrates usage of the plugin.

The `stringify()` function will convert any Variant type into an equivalent GDVN String, and the `parse()` and `parse_string()` functions will parse a GDVN String into its equivalent Variant.
GDVN Strings produced by `stringify()` are also valid JSON strings. See Godot's JSON docs for more detailed usage documentation.

Switching from using JSON to using GDVN is as easy as changing the `JSON` class name to `GDVN` in your code!


<br>
<br>
  
# Quick Docs

### `Error parse(gdvn_text: String, keep_text: bool)`
Non-static alternative to `parse_string()`. Returns an Error that can be used for custom error handling. The resulting data can be retrieved from the `data` member variable.

### `String get_error_message()`
Returns the error message from the last failed `parse()` call.

### `int get_error_line()`
Returns the line where the error occurred in the text of the last `parse()` call.

### `String get_parsed_text()`
Returns the text that was parsed during the last `parse()` cal, if `keep_text` was true.

#### `String stringify(data: Variant, indent: String = "    ", sort_keys: bool = false, full_precision: bool = false) static`
Converts `data` into a String formatted using the Variant's constructor syntax. If `data` is a Dictionary or Array, this is done recursively for every key:value pair or element, then the data is converted to a String in JSON format.

#### `Variant parse_string(data: String) static`
Converts a String encoded with `stringify()` back into a Variant.

## GDVN Exclusive

#### `Variant stringify_variants(data: Variant) static`
Converts a Variant into a String formatted using the Variant's constructor syntax. If `data` is a Dictionary or Array, this is done recursively for every key:value pair or element. Does not encode data into JSON format.

#### `Variant parse_variant_strings(data: Variant) static`
Converts a constructor syntax String back into a Variant. If `data` is a Dictionary or Array, this is done recursively for every key:value pair or element. Does not encode data into JSON format.

#### `Variant string_to_variant(data: String) static`
Converts a single constructor syntax String into a Variant.
