from argparse import ArgumentParser
import ast 

parser = ArgumentParser()
parser.add_argument('--urls', type=ast.literal_eval)
parser.add_argument('--playlist', type=str)
parser.add_argument('--domain', type=str)
parser.add_argument('--port', type=int)

print("Hello World!")

args = parser.parse_args()
print(args.urls, args.playlist, args.port, args.domain)