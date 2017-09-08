property WHITE_SPACES : { character id 9,  character id 10, character id 11,  character id 12, ¬
                          character id 13, character id 32, character id 133, character id 160 }

on strip(s)
    if s is equal to "" then
        return s
    end if

    repeat while first character of s is in WHITE_SPACES
        try
            set s to text 2 through -1 of s
        on error
            return ""
        end try
    end repeat

    repeat while last character of s is in WHITE_SPACES
        set s to text 1 through -2 of s
    end repeat

    return s
end strip

on replace(str, oldsubstr, newsubstr)
    # разбиваем
    set old_delimiter to text item delimiters of AppleScript
    set text item delimiters of AppleScript to oldsubstr
    set parts to every text item of str

    # собираем
    set text item delimiters of AppleScript to newsubstr
    set str to parts as text

    set text item delimiters of AppleScript to old_delimiter
    return str
end

on create_xmloutput()
    script XMLOutput
        property item_tags : {}

        on create_item(attributes)
            script XMLItemTag
                property attributes : {}

                property title_tag : missing value
                property subtitle_tags : {}
                property icon_tag : missing value
                property text_tags : {}

                on create_title(value)
                    script XMLTitleTag
                        property value : missing value

                        on is_empty()
                            return length of value is 0
                        end is_empty

                        on build_xml(indent)
                            return indent & "<title>" & escape_text_value(my value) & "</title>\n"
                        end build_xml
                    end script

                    set XMLTitleTag's value to (value as text)
                    set my title_tag to XMLTitleTag

                    return XMLTitleTag
                end create_title

                on create_subtitle(value, modifier)
                    script XMLSubtitleTag
                        property value : missing value
                        property modifier : missing value

                        on is_empty()
                            return length of value is 0
                        end is_empty

                        on build_xml(indent)
                            set opening_tag to "<subtitle"
                            if my modifier is not missing value then
                                set opening_tag to opening_tag & " mod=\"" & my modifier & "\""
                            end if
                            set opening_tag to opening_tag & ">"

                            set closing_tag to "</subtitle>\n"
                            return indent & opening_tag & escape_text_value(my value) & closing_tag
                        end build_xml
                    end script

                    set XMLSubtitleTag's value to (value as text)
                    if modifier is not missing value then
                        set modifier to modifier as text
                        if modifier is in { "shift", "fn", "ctrl", "alt", "cmd" } then
                            set XMLSubtitleTag's modifier to modifier
                        else
                            error "Incorrect subtitle modifier value" number 13
                        end if
                    end if

                    set end of my subtitle_tags to XMLSubtitleTag

                    return XMLSubtitleTag
                end

                on create_icon(value, type)
                    script XMLIconTag
                        property value : missing value
                        property type : missing value

                        on build_xml(indent)
                            set opening_tag to "<icon"
                            if my type is not missing value then
                                set opening_tag to opening_tag & " type=\"" & my type & "\""
                            end if
                            set opening_tag to opening_tag & ">"

                            set closing_tag to "</icon>\n"
                            return indent & opening_tag & escape_text_value(my value) & closing_tag
                        end build_xml
                    end script

                    set XMLIconTag's value to (value as text)
                    if type is not missing value then
                        set type to (type as text)
                        if type is in { "fileicon", "filetype" } then
                            set XMLIconTag's type to type
                        else
                            error "Incorrect icon type value" number 13
                        end if
                    end if

                    set my icon_tag to XMLIconTag
                    return XMLIconTag
                end create_icon

                on create_text(value, type)
                    script XMLTextTag
                        property value : missing value
                        property type : missing value

                        on build_xml(indent)
                            set opening_tag to "<text"
                            if my type is not missing value then
                                set opening_tag to opening_tag & " type=\"" & my type & "\""
                            end if
                            set opening_tag to opening_tag & ">"

                            set closing_tag to "</text>\n"
                            return indent & opening_tag & escape_text_value(my value) & closing_tag
                        end build_xml
                    end script

                    set XMLTextTag's value to (value as text)

                    set type to (type as text)
                    if type is not in { "copy", "largetype" } then
                        error "Incorrect text type value" number 13
                    end if
                    set XMLTextTag's type to type

                    set end of my text_tags to XMLTextTag
                    return XMLTextTag
                end create_text

                on create_bothtype_text(value)
                    return { my create_text(value, "copy"), ¬
                             my create_text(value, "largetype") }
                end create_bothtype_text

                on build_xml(indent)
                    set opening_tag to  indent & "<item"
                    repeat with attribute in my attributes
                        set opening_tag to opening_tag & " " & ¬
                                           name of attribute & "=\"" & ¬
                                           escape_attribute_value(value of attribute) & "\" "
                    end repeat
                    set opening_tag to opening_tag & ">\n"

                    set next_indent to indent & (first character of indent)

                    if my title_tag is not missing value then
                        set inner_xml to (my title_tag)'s build_xml(next_indent)
                    else
                        error "Item tag should have title tag" number 13
                    end if
                    repeat with subtitle_tag in my subtitle_tags
                        set inner_xml to inner_xml & subtitle_tag's build_xml(next_indent)
                    end repeat
                    if my icon_tag is not missing value then
                        set inner_xml to inner_xml & (my icon_tag)'s build_xml(next_indent)
                    end if
                    repeat with text_tag in my text_tags
                        set inner_xml to inner_xml & text_tag's build_xml(next_indent)
                    end repeat

                    set closing_tag to indent & "</item>\n"
                    return opening_tag & inner_xml & closing_tag
                end build_xml
            end script

            try
                set uid to (uid of attributes) as text
                set end of XMLItemTag's attributes to { name: "uid", value: uid }
            on error msg number n
                if n is not in { -1728, -1700 } then
                    error msn number n
                end if
            end

            try
                set arg to (arg of attributes) as text
                set end of XMLItemTag's attributes to { name: "arg", value: arg}
            on error msg number n
                if n is not in { -1728, -1700 } then
                    error msn number n
                end if
            end

            try
                set valid to valid of attributes

                if (class of valid is boolean and valid is true) or valid is "YES" then
                    set end of XMLItemTag's attributes to { name: "valid", value: "YES" }

                else if (class of valid is boolean and valid is false) or valid is "NO" then
                    set end of XMLItemTag's attributes to { name: "valid", value: "NO" }

                else
                    error "Incorrect value in valid attribute" number 13

                end if
            on error number -1728
            end

            try
                set autocomplete to (autocomplete of attributes) as text
                set end of XMLItemTag's attributes to { name: "autocomplete", value: autocomplete }
            on error msg number n
                if n is not in { -1728, -1700 } then
                    error msn number n
                end if
            end

            try
                set type to (type of attributes) as text
                if type is in { "default" , "file", "file:skipcheck" } then
                    set end of XMLItemTag's attributes to { name: "type", value: type}
                end if
            on error msg number n
                if n is not in { -1728, -1700 } then
                    error msn number n
                end if
            end

            set end of my item_tags to XMLItemTag
            return XMLItemTag
        end

        on escape_text_value(value)
            set value to replace(value, "<", "&lt;")
            set value to replace(value, ">", "&gt;")
            set value to replace(value, "&", "&amp;")
            return value
        end escape_text_value

        on escape_attribute_value(value)
            set value to escape_text_value(value)
            set value to replace(value, "'", "&apos;")
            set value to replace(value, "\"", "&quot;")
            return value
        end escape_attribute_value

        on total_item_count()
            return length of (my item_tags)
        end total_item_count

        on visible_item_count()
            set item_count to 0

            repeat with item_tag in (my item_tags)

                set subtitle_without_mod to missing value
                repeat with subtitle_tag in reverse of (subtitle_tags of item_tag)
                    if (modifier of subtitle_tag is missing value) then
                        set subtitle_without_mod to subtitle_tag
                        exit repeat
                    end if
                end repeat

                if (title_tag of item_tag is not missing value) and ¬
                   not (title_tag of item_tag)'s is_empty() or ¬
                   (subtitle_without_mod is not missing value) and ¬
                   not subtitle_without_mod's is_empty() then
                    set item_count to item_count + 1
                end if

            end repeat

            return item_count
        end visible_item_count

        on build_xml()
            set xml to "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<items>\n"

            repeat with item_tag in my item_tags
                set xml to xml & item_tag's build_xml("\t")
            end repeat

            set xml to xml & "</items>\n"
            return xml
        end build_xml

    end script
end create_xmloutput
