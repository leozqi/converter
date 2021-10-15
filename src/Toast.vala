class Toast : Gtk.Revealer {

private Gtk.Box container;
private Gtk.Label label;
private Gtk.Button close;

internal Toast (string message, string style="app-notification") {
	this.set_valign (Gtk.Align.START);
	this.set_halign (Gtk.Align.CENTER);
	this.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
	this.set_transition_duration (1000);
	this.set_reveal_child (true);

	this.container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18); //spacing=18
	this.container.get_style_context ().add_class (style);

	this.label = new Gtk.Label (message);

	// Pack options: widget, epxand, fill, padding
	this.container.pack_start (this.label, false, true, 18);

 	this.close = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
	this.close.set_relief (Gtk.ReliefStyle.NONE);
	this.close.set_receives_default (true);
	this.close.clicked.connect (this.exit);

	this.container.pack_start (close, false, true, 18);

	this.add (container);

	Timeout.add_full (5, 1000, this.animate_close);
}

bool animate_close () {
	if (this.get_reveal_child ()) {
		this.set_reveal_child (false);
	} else {
		exit ();
	}
	return true;
}

void exit () {
	this.label.destroy ();
	this.close.destroy ();
	this.container.destroy ();
	this.destroy ();
}

} /* End class Toast */
