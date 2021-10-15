class ConvertOpts {

private List<ConvertHandle> opts;

public ConvertOpts()
{
	this.opts = new List<ConvertHandle> ();
}


public bool has_converter(string from_t, string to_t)
{
	ConvertHandle h;
	for (uint i = 0; i < this.opts.length(); i++) {
		h = this.opts.nth_data(i);
		if (h.compatible (from_t, to_t)) {
			return true;
		}
	}
	return false;
}


public ConvertHandle? get_converter(string from_t, string to_t)
{
	ConvertHandle h;
	for (uint i = 0; i < this.opts.length(); i++) {
		h = this.opts.nth_data(i);
		if (h.compatible (from_t, to_t)) {
			return h;
		}
	}
	return null;
}


public void load_opts(Gtk.ComboBoxText from, Gtk.ComboBoxText to)
{
	ConvertHandle h;
	for (uint i = 0; i < this.opts.length (); i++) {
		h = this.opts.nth_data(i);
		from.append_text(h.get_from());
		to.append_text(h.get_to());
	}
}


public void parse_config (Json.Node root) throws ConfigError
{
	if (root.get_node_type () != Json.NodeType.ARRAY) {
		throw new ConfigError.INVALID ("Config file must have array as root.");
	}

	unowned Json.Array? specs = root.get_array ();

	unowned Json.Node? node_spec;
	unowned Json.Object? spec;

	string from;
	string to;
	string check;
	unowned Json.Array? commands;
	string command;
	List<string> command_list;

	for (uint i = 0; i < specs.get_length (); i++) {
		node_spec = specs.get_element (i);
		if (node_spec.get_node_type () != Json.NodeType.OBJECT) {
			throw new ConfigError.INVALID ("Config file must only have objects in array.");
		}
		spec = node_spec.get_object ();

		// Get three string fields
		from = spec.get_string_member ("from");
		to = spec.get_string_member ("to");
		check = spec.get_string_member ("check");
		commands = spec.get_array_member ("commands");

		// Get each command in commands field
		command_list = new List<string> ();
		for (uint j = 0; j < commands.get_length (); j++) {
			command = commands.get_string_element (j);
			if (command == "") {
				throw new ConfigError.INVALID ("Config file must have at least one string member in array commands");
			}
			command_list.append (command);
		}
		this.opts.append (new ConvertHandle (
			from,
			to,
			check,
			command_list
		));
	}
}


public string get_from (uint index) {
	return this.opts.nth_data(index).get_from ();
}

public string get_to (uint index)
{
	return this.opts.nth_data(index).get_to ();
}


} /* End class ConvertOpts */
