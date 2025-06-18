import xml.etree.ElementTree as ET
import csv
import io # Used to parse the string directly

# --- Configuration ---
csv_output_filename = 'wp_authors_output.csv'
# Define the namespace dictionary. Adjust the URI if needed.
namespaces = {'wp': 'http://wordpress.org/export/1.2/'}
# Define the headers for the CSV file (corresponds to tag names without prefix)
headers = ['term_id', 'term_taxonomy', 'term_slug', 'term_parent', 'term_name']

# --- Helper function to safely get text ---
def get_element_text(element, tag_name, ns):
    """Safely find a child element and return its text, or empty string."""
    child = element.find(tag_name, ns)
    if child is not None and child.text is not None:
        return child.text.strip()
    return ''

# --- Main Parsing Logic ---
try:

    print("comenzando proceso")
    # Cargar el XML desde un archivo o string
    with open('terms_xml.xml', 'r', encoding='utf-8') as file:
        xml_data = file.read()
    # Parse the XML data from the string
    root = ET.fromstring(xml_data)

    # Open the CSV file for writing
    # Use newline='' to prevent extra blank rows in the CSV
    # Use encoding='utf-8' to handle special characters
    with open(csv_output_filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)

        # Write the header row
        writer.writerow(headers)

        # Find all <wp:term> elements using the namespace
        # The './/' prefix means find the element anywhere under the current node
        for term_element in root.findall('.//wp:term', namespaces):
            # Extract data for each field using the helper function
            term_id = get_element_text(term_element, 'wp:term_id', namespaces)
            term_taxonomy = get_element_text(term_element, 'wp:term_taxonomy', namespaces)
            term_slug = get_element_text(term_element, 'wp:term_slug', namespaces)
            term_parent = get_element_text(term_element, 'wp:term_parent', namespaces)
            term_name = get_element_text(term_element, 'wp:term_name', namespaces)

            # Write the extracted data as a row in the CSV
            writer.writerow([term_id, term_taxonomy, term_slug, term_parent, term_name])

    print(f"Successfully parsed XML and created CSV file: {csv_output_filename}")

except ET.ParseError as e:
    print(f"Error parsing XML: {e}")
except IOError as e:
    print(f"Error writing to CSV file: {e}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")