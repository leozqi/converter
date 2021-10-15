errordomain Converter {
	PATHERROR
}

class FileList : Gtk.ScrolledWindow {

public Gtk.ListStore model = new Gtk.ListStore (3,
	typeof (string),
	typeof (string),
	typeof (string)
);

private enum Column {
	NAME,
	PATH,
	TYPE,
}

public FileList ()
{
	Object (hadjustment: null, vadjustment: null);

	var view = new Gtk.TreeView ();
	view.set_model (this.model);

	var cell = new Gtk.CellRendererText ();

	/* 'weight' refers to font boldness.
	 *  400 is normal.
	 *  700 is bold.
	 */
	cell.set ("weight_set", true);
	cell.set ("weight", 700);

	/*columns*/
	view.insert_column_with_attributes (-1, "Name", cell, "text", Column.NAME);
	view.insert_column_with_attributes (-1, "File path", cell, "text", Column.PATH);
	view.insert_column_with_attributes (-1, "Type", new Gtk.CellRendererText (), "text", Column.TYPE);

	view.expand = true;

	var selection = view.get_selection ();
	selection.changed.connect (this.on_changed);

	this.add (view);
}


/**
 * File `f` should be guaranteed to exist: this function will throw an Error
 * otherwise.
 */
public void add_file (File f) throws Converter.PATHERROR
{
	if (!f.query_exists ()) {
		throw new Converter.PATHERROR ("File path does not exist.");
	}

	try {
		FileInfo i = f.query_info ("standard::*", 0);

		Gtk.TreeIter iter;
		this.model.append (out iter);
		this.model.set (iter,
			Column.NAME, i.get_display_name (),
			Column.PATH, f.get_path (),
			Column.TYPE, i.get_content_type ()
		);
	} catch (Error e) {
		throw new Converter.PATHERROR (e.message);
	}
}


public void on_changed (Gtk.TreeSelection selection)
{
	Gtk.TreeModel model;
	Gtk.TreeIter iter;
	string path;
	string type;

	if (selection.get_selected (out model, out iter)) {
		model.get (iter,
			Column.PATH, out path,
			Column.TYPE, out type
		);
	}
}


public string get_filename (Gtk.TreeIter iter)
{
	Value name = Value (typeof (string));
	this.model.get_value (iter, 0, out name);
	print(@"Name is $(name.get_string ())");
	return name.get_string ();
}


public string get_filepath (Gtk.TreeIter iter)
{
	Value path = Value (typeof (string));
	this.model.get_value (iter, 1, out path);
	print(@"Path is $(path.get_string ())");
	return path.get_string ();
}


public string get_filetype (Gtk.TreeIter iter)
{
	Value type = Value (typeof (string));
	this.model.get_value (iter, 2, out type);
	print(@"Type is $(type.get_string ())");
	return type.get_string ();
}


public void get_iter_first (out Gtk.TreeIter iter)
{
	this.model.get_iter_first (out iter);
}


public bool iter_next (ref Gtk.TreeIter iter) {
	return this.model.iter_next (ref iter);
}

} /* End class FileList */
