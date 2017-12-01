string __mummery_version = "1.0";

Record Button
{
	int option;
	string name;
	string description;
	int ordering;
};

void main()
{
	string [string] shorthand_descriptions;
	shorthand_descriptions["The Captain"] = "+15%? meat";
	shorthand_descriptions["Prince George"] = "+15%? item";
	shorthand_descriptions["Beelzebub"] = "MP regen/fight";
	shorthand_descriptions["Saint Patrick"] = "+2? muscle stats/fight";
	shorthand_descriptions["Oliver Cromwell"] = "+2? myst stats/fight";
	shorthand_descriptions["The Doctor"] = "HP regen/fight";
	shorthand_descriptions["Miss Funny"] = "+2? moxie stats/fight";
	int [string] ordering;
	ordering["The Captain"] = 0;
	ordering["Prince George"] = 1;
	ordering["The Doctor"] = 2; //"HP regen/fight";
	ordering["Beelzebub"] = 3; //"MP regen/fight";
	ordering["Saint Patrick"] = 4; //"+2? muscle stats/fight";
	ordering["Oliver Cromwell"] = 5; //"+2? myst stats/fight";
	ordering["Miss Funny"] = 6; //"+2? moxie stats/fight";
	ordering["Never Mind"] = 10000;

	buffer page_text = visit_url();
	
	string [int][int] form_matches = page_text.group_string("<form.*?</form>");
	
	string new_buttons = "You dig through the mumming trunk to see what costumes are inside.";
	
	new_buttons += "<style type=\"text/css\">";
	new_buttons += ".mumm_button:hover { background:#E1E3E7;cursor:pointer;border-radius:5px; }";
	new_buttons += ".mumm_button { padding:10px; text-align:center;background:none; border:none; font-size:1.0em; width:100%;	}";
	new_buttons += ".mumm_header { font-size:1.3em; font-weight:bold; }";
	new_buttons += ".mumm_description { color:#333333; }";
	
	new_buttons += "</style>";
	boolean within_table = true;
	new_buttons += "<div style=\"max-width:600px;display:table;\">";
	new_buttons += "<div style=\"display:table-row;\">";
	int entries_in_row = 0;
	int entries_per_row = ceil(to_float(form_matches.count() - 1) / 2.0);
	
	Button [int] buttons;
	foreach key in form_matches
	{
		Button b;
		//<input class=button type=submit value="Never Mind">
		string text = form_matches[key][0];
		b.option = text.group_string("<input[ ]*type=hidden[ ]*name=option[ ]*value=([0-9]*)")[0][1].to_int();
		b.name = text.group_string("<input[ ]*class=button[ ]*type=submit[ ]*value=\"(.*?)\"")[0][1];
		b.description = text.group_string("<b>(.*?)</b>")[0][1];
		if (shorthand_descriptions contains b.name && false)
			b.description = shorthand_descriptions[b.name];
		b.ordering = ordering[b.name];
		buttons[buttons.count()] = b;
	}
	sort buttons by value.ordering;
	
	foreach key, b in buttons
	{
		string image_url = "";
		if (b.option >= 1 && b.option <= 7)
			image_url = "images/itemimages/mummericon" + b.option + ".gif";
			
		if (entries_in_row >= entries_per_row)
		{
			new_buttons += "</div><div style=\"display:table-row;\">";
			entries_in_row = 0;
		}
		if (b.name == "Never Mind")
		{
			new_buttons += "</div></div>";
			entries_in_row = 0;
			within_table = false;
		}
		//new_buttons += option + ": \"" + b.name + "\", b.description: \"" + b.description + "\"";
		
		new_buttons += "<div style=\"display:table-cell;vertical-align:top;";
		if (b.name == "Never Mind")
			new_buttons += "width:100%;display:block;text-align:center;";
		new_buttons += "\">";
		
		new_buttons += "<form name=\"choiceform" + b.option + "\" action=\"choice.php\" method=\"post\">";
		
		new_buttons += "<input type=\"hidden\" name=\"whichchoice\" value=\"1271\">";
		new_buttons += "<input type=\"hidden\" name=\"pwd\" value=\"" + my_hash() + "\">";
		new_buttons += "<input type=\"hidden\" name=\"option\" value=" + b.option + ">";
		new_buttons += "<button type=\"submit\" class=\"mumm_button\"";
		new_buttons += ">";
		if (image_url != "")
		{
			new_buttons += "<div style=\"margin-left:auto;margin-right:auto;\">";
			new_buttons += "<img src=\"" + image_url + "\" style=\"padding:5px;mix-blend-mode:multiply;\">";
			new_buttons += "</div>";
		}
		new_buttons += "<div class=\"mumm_header\">";
		new_buttons += b.name;
		new_buttons += "</div>";
		if (b.description != "")
			new_buttons += "<span class=\"mumm_description\">" + b.description + "</span>";
		new_buttons += "</button>";
		
		new_buttons += "</form></div>";
		
		entries_in_row++;
	}
	if (within_table)
	{
		if (entries_in_row > 0)
			new_buttons += "</div>";
		new_buttons += "</div>";
	}
	
	matcher m = create_matcher("You dig through the mumming trunk to see what costumes are inside..*?</center>", page_text);
	
	
	string new_page_text = replace_all(m, new_buttons);
	new_page_text = new_page_text.replace_string("<b>Mummery</b>", "<b>Mummery v" + __mummery_version + "</b>");
	write(new_page_text);
}