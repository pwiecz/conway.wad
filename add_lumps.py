import sys
import argparse
import omg

parser = argparse.ArgumentParser(description='Add MAPINFO and UMAPINFO lumps to a WAD file.')
parser.add_argument('-i',dest='input',help='input WAD file',required=True)
parser.add_argument('-o',dest='output',help='output WAD file',required=True)
parser.add_argument('-m',dest='mapinfo',help='file with mapinfo data')
parser.add_argument('-z',dest='zmapinfo',help='file with zmapinfo data')
parser.add_argument('-u',dest='umapinfo',help='file with umapinfo data')
parser.add_argument('-d',dest='dehacked',help='file with dehacked data')
args = parser.parse_args()

w = omg.WAD(from_file=args.input)
if args.mapinfo is not None:
  w.data['MAPINFO'] = omg.Lump(from_file=args.mapinfo)
if args.zmapinfo is not None:
  w.data['ZMAPINFO'] = omg.Lump(from_file=args.zmapinfo)
if args.umapinfo is not None:
  w.data['UMAPINFO'] = omg.Lump(from_file=args.umapinfo)
if args.dehacked is not None:
  w.data['DEHACKED'] = omg.Lump(from_file=args.dehacked)
w.to_file(args.output)
