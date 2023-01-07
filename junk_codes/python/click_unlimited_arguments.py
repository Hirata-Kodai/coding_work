import click


@click.command()
@click.argument("args", nargs=-1)
def main(args):
    print(args)


if __name__ == '__main__':
    main()
