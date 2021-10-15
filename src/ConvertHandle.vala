public class ConvertHandle {

private string from;
private string to;
private string check;
private string[] commands;

internal ConvertHandle (string from, string to, string check, List<string> commands) {
	this.from = from;
	this.to = to;
	this.check = check;

	this.commands = new string[commands.length()];
	for (uint i = 0; i < commands.length(); i++) {
		this.commands[i] = commands.nth_data(i);
	}
}

public bool compatible (string ofrom, string oto) {
	if ((this.from == ofrom) && (this.to == oto)) {
		return true;
	} else {
		return false;
	}
}

public string get_from () {
	return this.from;
}

public string get_to () {
	return this.to;
}

/**
 * All ConvertHandle classes must override this method
 * string in : path of input file
 * string out : path of output file
 * command : printf-style string with TWO %s:
 *     * 1st for string in
 *     * 2nd for string out
 *
 * Return: true if conversion successful
 */
public bool convert (string in_path, string out_path, string prefix="", int p_first = -1,
	int p_last = -1)
{
	string exec = "";

	string m_stdout = "";
	string m_stderr = "";
	int m_status = 0;

	foreach (string command in this.commands) {
		exec = template (command, in_path, out_path, p_first, p_last, prefix);
		print (exec);
		try {
			Process.spawn_command_line_sync (
				exec,
				out m_stdout,
				out m_stderr,
				out m_status
			);

			if (m_status != 0) {
				return false;
			}
		} catch (SpawnError e) {
			return false;
		}
	}
	return true;
}

private string template (string command, string in_path, string out_path,
	int p_first = -1, int p_last = -1, string prefix="")
{
	string ret = command.replace ("<IN>", in_path.escape() );
	ret = ret.replace ("<OUT>", out_path.escape() );

	if (p_first >= 0) {
		ret = ret.replace ("<FIRSTPAGE>", @"-f $p_first");
	} else {
		ret = ret.replace ("<FIRSTPAGE>", "");
	}

	if (p_last >= p_first && p_last >= 0) {
		ret = ret.replace ("<LASTPAGE>", @"-l $p_last");
	} else {
		ret = ret.replace ("<LASTPAGE>", "");
	}

	ret = ret.replace ("<PREFIX>", prefix.escape ());

	return ret;
}

} /* End class ConvertHandle */
