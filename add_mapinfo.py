import sys
import argparse
import omg

parser = argparse.ArgumentParser(description='Add MAPINFO and UMAPINFO lumps to a WAD file.')
parser.add_argument('-i',dest='input',help='input WAD file',required=True)
parser.add_argument('-o',dest='output',help='output WAD file',required=True)
parser.add_argument('-m',dest='mapinfo',help='file with mapinfo data')
parser.add_argument('-u',dest='umapinfo',help='file with umapinfo data')
args = parser.parse_args()

w = omg.WAD(from_file=args.input)
if args.mapinfo is not None:
  w.data['MAPINFO'] = omg.Lump(from_file=args.mapinfo)
if args.umapinfo is not None:
  w.data['UMAPINFO'] = omg.Lump(from_file=args.umapinfo)
w.to_file(args.output)
