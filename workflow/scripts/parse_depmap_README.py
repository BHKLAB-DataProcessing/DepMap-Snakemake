def parse_content(content):
    sections = ["Overview", "Pipelines", "Files"]
    dict_content = {section: "" if section == "Overview" else {} for section in sections}
    
    content_lines = content.split("\n")
    section = None
    subsection = None
    
    for line in content_lines:
        # Skip empty lines
        if not line.strip():
            continue

        line_clean = line.strip("# ")
        # If line is a section heading
        if line_clean in sections:
            section = line_clean
            continue

        # If line is a subsection heading
        # Skip if we haven't reached a main section
        if "###" in line and section != "Overview":
            if section is None:
                continue
            subsection = line_clean
            dict_content[section][subsection] = ""
            continue
        
        # If line is regular text
        if section:
            # For "Overview" section, content is combined into one string
            if section == "Overview":
                dict_content[section] += line_clean
            # For "Pipelines" and "Files" sections, content is added under specific subsection
            else:
                if subsection:  # ensure there is a subsection to avoid KeyErrors
                    dict_content[section][subsection] += line_clean
                else: 
                    print(f"Unexpected line under section {section} with no subsection: {line_clean}")

    return dict_content

# Parse each file's content into JSON
file1_json = parse_content(file1_content)
file2_json = parse_content(file2_content)
file3_json = parse_content(file3_content)
file4_json = parse_content(file4_content)

# Save them into separate JSON files
with open("/mnt/data/file1.json", "w") as outfile:
    json.dump(file1_json, outfile)
    
with open("/mnt/data/file2.json", "w") as outfile:
    json.dump(file2_json, outfile)

with open("/mnt/data/file3.json", "w") as outfile:
    json.dump(file3_json, outfile)

with open("/mnt/data/file4.json", "w") as outfile:
    json.dump(file4_json, outfile)
    
    