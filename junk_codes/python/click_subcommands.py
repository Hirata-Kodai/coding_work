import click


@click.group()
@click.option("--debug", is_flag=True)
@click.pass_context
def cli(ctx, debug):
    ctx.obj["DEBUG"] = debug


@cli.command()
@click.pass_context
def hoge(ctx):
    if ctx.obj["DEBUG"]:
        print("debug mode")
    else:
        print("This function is hoge subcommand!")


def main():
    cli(obj={})  # obj はキーワード引数


if __name__ == '__main__':
    main()
