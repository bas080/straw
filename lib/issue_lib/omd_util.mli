val title_of_doc : 'a Omd.block list -> string option

val extract_links
    : (string * string) list
    -> string
    -> (string * string) list Omd.inline list

val replace_text_with_links
    : (string * string) list Omd.block list
    -> (string * string) list Omd.block list
