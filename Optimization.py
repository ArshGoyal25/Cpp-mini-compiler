
# def print_optimized_icg():
#     for id in st_dict:
#         print(id + ' = ' + st_dict[id][0])
# st_dict=dict()
# i=0
# for line in symbol_table:
#     line=line.split()
#     if len(line)==0 or line[0]=='Name' or line[0][0]=='-':
#         pass
#     else:
#         identifier=line[0]
#         if identifier not in st_dict:
#             st_dict[identifier]=[]
#             st_dict[identifier].append(line[3])
#             st_dict[identifier].append(line[-1]) 

#         else:
#             if st_dict[identifier][-1]==line[-1]:
#                 st_dict[identifier]=[]
#                 st_dict[identifier].append(line[3])
#                 st_dict[identifier].append(line[-1])
#             else:
#                 # print_optimized_icg()
#                 pass

#         # print(line)

# # print(st_dict)
# print_optimized_icg()

class Table:
    def __init__(self, Name, Value, Scope, Block):
        self.name = Name
        self.value = Value
        self.scope = Scope
        self.block = Block

    def __repr__(self):
        return '{' + self.name + ', ' + self.value + ', ' + self.scope + ', ' + self.block +'}'

def read_symbol_table(symbol_table,optimized_icg):
    all_lines = []
    for line in symbol_table:
        line = line.split()
        if len(line)==0 or line[0]=='Name' or line[0][0]=='-':
            pass
        else:
            Name = line[0]
            Value = line[3]
            Scope = line[6]
            Block = line[7]
            entry_line = Table(Name,Value,Scope,Block)
            all_lines.append(entry_line)
    all_lines.sort(key=lambda x: x.block)
    for i in all_lines:
        print(i)




if __name__ == "__main__":
    symbol_table=open('symbol_table.txt','r+')
    icg=open('icg.txt','r+')
    optimized_icg = open('optimized_icg.txt','w')

    optimized_icg.flush()
    read_symbol_table(symbol_table,optimized_icg)

    
    optimized_icg.close()
    icg.close()
    symbol_table.close()