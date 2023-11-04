@tool
extends Resource

class_name GDVN

## Godot Variant Notation (GDVN)
##
## GDVN is a notation written on top of JSON
## that provides a consistent conversion between
## Godot Variant types and JSON-supported types.
##
## To solve the problem of easy conversion, the format
## converts Variants to strings by encoding them using
## their constructor's syntax. For example:
##
##[codeblock]
##
## var vec = Vector2(123, 456)
## var as_string = GDVN.stringify(vec)
## print(as_string)
##
## Output: "Vector2(123, 456)"
##
##[/codeblock]
##
## The strings are converted back into Variants
## using Expressions, which are able to parse the
## constructor of any Variant type.


## List of supported Variant constructors
## Used for validation when converting strings to variants.
static var constructor_validation_strings: Array = [
	"Vector2",
	"Vector2i",
	"Vector3",
	"Vector3i",
	"Vector4",
	"Vector4i",
	"Rect2",
	"Rect2i",
	"Plane",
	"Quaternion",
	"Color",
	"int",
	"float",
	"bool"
]

## Stores the result of a successful `parse()` call.
var data: Variant

## The original text from the last `parse()` call where `keep_text` was true.
var parsed_text: String

## The line in the text where the last `parse()` call failed.
var error_line: int

## The resulting error message from the last failed `parse()` call.
var error_message: String


## Non-static alternative to `parse_string()`. Returns an Error
## that can be used for custom error handling. The resulting data
## can be retrieved from the `data` member variable.
func parse(gdvn_text: String, keep_text: bool = false, typed_arrays: bool = false) -> Error:
	
	if keep_text: parsed_text = gdvn_text
	
	if gdvn_text.begins_with("{") || gdvn_text.begins_with("["):
		
		var json: JSON = JSON.new()
		var err: Error = json.parse(gdvn_text, keep_text)
		
		error_line = json.get_error_line()
		error_message = json.get_error_message()
		
		if err == OK:
			
			var json_data: Variant = json.data
			data = parse_variant_strings(json_data, typed_arrays)
			
			return err
		
		return err
	
	else:
		
		data = parse_variant_strings(gdvn_text, typed_arrays)
		
		return OK


## Retrieve the error message from the last failed `parse()` call.
func get_error_message() -> String:
	return error_message


## Retrieve the error line from the last failed `parse()` call.
func get_error_line() -> int:
	return error_line


## Retrieve the text that was parsed during the last `parse()` call,
## if `keep_text` was true.
func get_parsed_text() -> String:
	return parsed_text


## Converts a Variant to a String represented
## by the Variant's constructor syntax. If `data` is a 
## Dictionary or Array, a JSON formatted String is returned.
static func stringify(variant_data: Variant, indent: String = "    ", sort_keys: bool = false, full_precision: bool = false) -> String:
	
	var gdvn: Variant = stringify_variants(variant_data)
	
	if gdvn is Dictionary || gdvn is Array:
		return JSON.stringify(variant_data, indent, sort_keys, full_precision)
	
	return gdvn


## Converts a String encoded with `stringify()` back into
## its equivalent Variant, and returns it. If `typed_arrays` is
## true, arrays of like-typed values will be returned as TypedArrays.
static func parse_string(gdvn_text: String, typed_arrays: bool = false) -> Variant:
	
	if gdvn_text.begins_with("{") || gdvn_text.begins_with("["):
		
		var json: Variant = JSON.parse_string(gdvn_text)
		var gdvn: Variant = parse_variant_strings(json, typed_arrays)
		
		return gdvn
	
	else:
		
		var gdvn: Variant = parse_variant_strings(gdvn_text, typed_arrays)
		
		return gdvn


## Recursively turns variants into strings representing their constructor syntax,
## but does not convert it to JSON format.
static func stringify_variants(variant_data: Variant) -> Variant:
	
	match typeof(variant_data):
		
		TYPE_STRING:
			return variant_data
		
		TYPE_BOOL:
			return "bool(%s)" % variant_data
		
		TYPE_FLOAT:
			return "float(%s)" % variant_data
		
		TYPE_INT:
			return "int(%s)" % variant_data
		
		TYPE_VECTOR2:
			return "Vector2(%s, %s)" % [variant_data.x, variant_data.y]
		
		TYPE_VECTOR2I:
			return "Vector2i(%s, %s)" % [variant_data.x, variant_data.y]
		
		TYPE_VECTOR3:
			return "Vector3(%s, %s, %s)" % [variant_data.x, variant_data.y, variant_data.z]
		
		TYPE_VECTOR3I:
			return "Vector3i(%s, %s, %s)" % [variant_data.x, variant_data.y, variant_data.z]
		
		TYPE_VECTOR4:
			return "Vector4(%s, %s, %s, %s)" % [variant_data.w, variant_data.x, variant_data.y, variant_data.z]
		
		TYPE_VECTOR4I:
			return "Vector4i(%s, %s, %s, %s)" % [variant_data.w, variant_data.x, variant_data.y, variant_data.z]
		
		TYPE_PLANE:
			return "Plane(%s, %s, %s, %s)" % [variant_data.normal.x, variant_data.normal.y, variant_data.normal.z, variant_data.d]
		
		TYPE_QUATERNION:
			return "Quaternion(%s, %s, %s, %s)" % [variant_data.x, variant_data.y, variant_data.z, variant_data.w]
		
		TYPE_RECT2:
			return "Rect2(%s, %s, %s, %s)" % [variant_data.position.x, variant_data.position.y, variant_data.size.x, variant_data.size.y]
		
		TYPE_RECT2I:
			return "Rect2i(%s, %s, %s, %s)" % [variant_data.position.x, variant_data.position.y, variant_data.size.x, variant_data.size.y]
		
		TYPE_COLOR:
			return "Color(%s, %s, %s, %s)" % [variant_data.r, variant_data.g, variant_data.b, variant_data.a]
		
		TYPE_DICTIONARY:
			
			var new_data: Dictionary = variant_data.duplicate(true)
			
			# Convert all the keys
			var new_keys: Dictionary = {}
			
			for key in new_data.keys():
				new_keys[stringify_variants(key)] = new_data[key]
				new_data.erase(key)
			
			new_data.merge(new_keys)
			
			# Then convert the values
			for k in new_data:
				new_data[k] = stringify_variants(new_data[k])
				
			return str(new_data)
		
		TYPE_ARRAY:
			
			var new_data: Array = variant_data.duplicate(true)
			
			# If the array is typed, create a new un-typed version
			if new_data.get_typed_builtin() != TYPE_NIL:
				new_data = Array(new_data, TYPE_NIL, "", null)
			
			for i in new_data.size():
				new_data[i] = stringify_variants(new_data[i])
			
			return str(new_data)
	
		_:
			return str(variant_data)


## Convert constructor syntax strings into variants. Recursively
## converts all array elements and dictionary keys/values. If `typed_arrays`
## is true, an array of like-typed values will be returned as a TypedArray.
static func parse_variant_strings(variant_data: Variant, typed_arrays: bool = false) -> Variant:
	
	match typeof(variant_data):
		
		TYPE_STRING:
			
			return string_to_variant(variant_data)
		
		TYPE_DICTIONARY:
			
			var new_data: Dictionary = variant_data.duplicate(true)
			
			# Convert all the keys
			var new_keys: Dictionary = {}
			
			for key in new_data.keys():
				new_keys[parse_variant_strings(key, typed_arrays)] = new_data[key]
				new_data.erase(key)
			
			new_data.merge(new_keys)
			
			# Then convert the values
			for k in new_data:
				new_data[k] = parse_variant_strings(new_data[k], typed_arrays)
			
			return new_data
		
		TYPE_ARRAY:
			
			var new_data: Array = variant_data.duplicate(true)
			
			for i in new_data.size():
				new_data[i] = parse_variant_strings(new_data[i], typed_arrays)
			
			if typed_arrays:
			
				var element_type: int = typeof(new_data[0])
				var type_check: Callable = func(element): return typeof(element) == element_type 
				
				# Check if all elements are of the same type.
				# If they are, create a new builtin typed array.
				if new_data.all(type_check):
					new_data = Array(new_data, element_type, "", null)
			
			return new_data
		
		_:
			return variant_data


## Convert a single constructor syntax string into a variant
static func string_to_variant(gdvn_text: String) -> Variant:
	
	var splits: PackedStringArray = gdvn_text.split("(")
	
	# Do some validation to confirm the correct constructor syntax
	if splits.size() == 2 && splits[1].ends_with(")") && constructor_validation_strings.has(splits[0]):
		
		var exp: Expression = Expression.new()
		var err: Error = exp.parse(gdvn_text)
		
		if err != OK:
			return gdvn_text
		
		var value: Variant = exp.execute()
		
		if exp.has_execute_failed():
			return gdvn_text
		
		return value
	
	return gdvn_text
