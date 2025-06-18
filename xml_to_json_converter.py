import xml.etree.ElementTree as ET
import json
from html import unescape

def parse_wordpress_xml(xml_file):
    # Parse XML file
    tree = ET.parse(xml_file)
    root = tree.getroot()
    channel = root.find('channel')
    
    # Initialize data structure
    data = {
        'channel_info': {},
        'authors': [],
        'categories': [],
        'tags': [],
        'terms': [],
        'items': []
    }
    
    # Extract channel information
    basic_fields = ['title', 'link', 'description', 'pubDate', 'language']
    wp_fields = ['{http://wordpress.org/export/1.2/}wxr_version', 
                 '{http://wordpress.org/export/1.2/}base_site_url',
                 '{http://wordpress.org/export/1.2/}base_blog_url']
    
    for field in basic_fields:
        element = channel.find(field)
        if element is not None:
            data['channel_info'][field] = element.text
            
    for field in wp_fields:
        element = channel.find(field)
        if element is not None:
            # Remove namespace from field name
            clean_field = field.split('}')[-1]
            data['channel_info'][clean_field] = element.text

    # Extract authors
    for author in channel.findall('{http://wordpress.org/export/1.2/}author'):
        author_data = {}
        for child in author:
            # Remove namespace from tag
            tag = child.tag.split('}')[-1]
            # Handle CDATA sections
            if child.text and child.text.startswith('<![CDATA['):
                author_data[tag] = child.text[9:-3]  # Remove CDATA wrapper
            else:
                author_data[tag] = child.text
        data['authors'].append(author_data)

    # Extract categories
    for category in channel.findall('wp:category', {'wp': 'http://wordpress.org/export/1.2/'}):
        cat_data = {}
        for child in category:
            tag = child.tag.split('}')[-1]
            if child.text and child.text.startswith('<![CDATA['):
                cat_data[tag] = child.text[9:-3]
            else:
                cat_data[tag] = child.text
        data['categories'].append(cat_data)

    # Extract tags
    for tag in channel.findall('wp:tag', {'wp': 'http://wordpress.org/export/1.2/'}):
        tag_data = {}
        for child in tag:
            tag_name = child.tag.split('}')[-1]
            if child.text and child.text.startswith('<![CDATA['):
                tag_data[tag_name] = child.text[9:-3]
            else:
                tag_data[tag_name] = child.text
        data['tags'].append(tag_data)

    # Extract terms
    for term in channel.findall('wp:term', {'wp': 'http://wordpress.org/export/1.2/'}):
        term_data = {}
        for child in term:
            tag_name = child.tag.split('}')[-1]
            if child.text and child.text.startswith('<![CDATA['):
                term_data[tag_name] = child.text[9:-3]
            else:
                term_data[tag_name] = child.text
        data['terms'].append(term_data)

    # Extract items
    for item in channel.findall('item'):
        item_data = {}
        
        # Basic fields
        for child in item:
            tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
            
            # Skip categories as they'll be handled separately
            if tag == 'category':
                continue
                
            # Handle CDATA sections
            if child.text and child.text.startswith('<![CDATA['):
                item_data[tag] = child.text[9:-3]
            else:
                item_data[tag] = child.text if child.text else None

        # Handle categories separately
        categories = []
        for category in item.findall('category'):
            cat_data = {
                'domain': category.get('domain'),
                'nicename': category.get('nicename'),
                'name': category.text[9:-3] if category.text and category.text.startswith('<![CDATA[') else category.text
            }
            categories.append(cat_data)
        item_data['categories'] = categories

        # Handle postmeta
        postmeta = []
        for meta in item.findall('wp:postmeta', {'wp': 'http://wordpress.org/export/1.2/'}):
            meta_key = meta.find('wp:meta_key', {'wp': 'http://wordpress.org/export/1.2/'}).text
            meta_value = meta.find('wp:meta_value', {'wp': 'http://wordpress.org/export/1.2/'}).text
            postmeta.append({
                'key': meta_key,
                'value': meta_value
            })
        item_data['postmeta'] = postmeta

        data['items'].append(item_data)

    return data

def convert_xml_to_json(xml_file, json_file):
    # Parse XML and convert to JSON
    data = parse_wordpress_xml(xml_file)
    
    # Write to JSON file with proper formatting and encoding
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    input_file = "../OneDrive/Documentos/Desarrollos/Trabajo/ATE/migracion_mediateca/ejemplo_migracion.xml"
    output_file = "wordpress_export.json"
    convert_xml_to_json(input_file, output_file)
    print(f"Conversion completed. JSON file saved as {output_file}")
