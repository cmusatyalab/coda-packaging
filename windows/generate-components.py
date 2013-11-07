# Build WiX ComponentGroup from a directory tree.

from cStringIO import StringIO
import os
import sys
from xml.dom import minidom
import xml.etree.ElementTree as et

NS = 'http://schemas.microsoft.com/wix/2006/wi'

def ns(name):
    return '{%s}%s' % (NS, name)


def path_to_id(typecode, path):
    return typecode + '_' + path.replace(os.sep, '_').translate(None, '-+')


def add_components_for_dir(component_ids, element, basedir, relpath=None):
    # Generate lists
    dirpath = os.path.join(basedir, relpath) if relpath else basedir
    files = []
    dirs = []
    for filename in os.listdir(dirpath):
        if relpath:
            file_relpath = os.path.join(relpath, filename)
        else:
            file_relpath = filename
        if os.path.isfile(os.path.join(dirpath, filename)):
            files.append((filename, file_relpath))
        else:
            dirs.append((filename, file_relpath))

    # Files
    for filename, file_relpath in files:
        has_checksum = os.path.splitext(filename)[1] in \
                ('.exe', '.dll', '.pyd')
        component_id = path_to_id('c', file_relpath)
        component = et.SubElement(element, ns('Component'), Id=component_id)
        et.SubElement(component, ns('File'),
                Id=path_to_id('f', file_relpath),
                Source=os.path.join(basedir, file_relpath),
                KeyPath='yes', Checksum='yes' if has_checksum else 'no')
        component_ids.append(component_id)

    # Subdirectories
    for subdirname, subdir_relpath in dirs:
        subdir_elt = et.SubElement(element, ns('Directory'),
                Id=path_to_id('d', subdir_relpath),
                Name=subdirname)
        add_components_for_dir(component_ids, subdir_elt, basedir,
                subdir_relpath)


# Create document
root = et.Element(ns('Include'))

# Build components and files
directory_ref = et.SubElement(root, ns('DirectoryRef'), Id='INSTALLDIR')
component_ids = []
add_components_for_dir(component_ids, directory_ref, sys.argv[1])

# Build component group
component_group = et.SubElement(root, ns('ComponentGroup'),
        Id='FileComponents')
for component_id in component_ids:
    et.SubElement(component_group, ns('ComponentRef'), Id=component_id)

# Print XML
et.register_namespace('', NS)
buf = StringIO()
et.ElementTree(root).write(buf, encoding='UTF-8', xml_declaration=True)
# Use minidom to pretty-print
dom = minidom.parseString(buf.getvalue())
print dom.toprettyxml(indent='  ', encoding='UTF-8')
