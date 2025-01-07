from configparser import ConfigParser

def config(filename="database.ini", section="postgresql"):
    # Create a parser
    parser = ConfigParser()

    # Read the config file
    parser.read(filename)

    # Get the section
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception(f"Section {section} not found in the {filename} file")

    return db
