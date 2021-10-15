/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Leo Qi <leozhaoqi@gmail.com>
 */

public class App : Gtk.Application {
	public App () {
		Object (
			application_id: "com.github.leozqi.converter",
			flags: ApplicationFlags.FLAGS_NONE
		);
	}

	protected override void activate () {

		/* Create new Window and show all the things. */
		new MainWindow (this).show_all ();
	}

	public static int main (string[] args) {
		return new App ().run (args);
	}
}
