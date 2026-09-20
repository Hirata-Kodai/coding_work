from jinja2 import Template, Environment, FileSystemLoader


env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('template.jinja2')

data = {
    "character": "料理",
}

rendered = template.render(data)

print(str(rendered))
