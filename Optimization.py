symbol_table=open('symbol_table.txt','r+')
icg=open('icg.txt','r+')


def print_optimized_icg():
    for id in st_dict:
        print(id + ' = ' + st_dict[id][0])
st_dict=dict()
i=0
for line in symbol_table:
    line=line.split()
    if len(line)==0 or line[0]=='Name' or line[0][0]=='-':
        pass
    else:
        identifier=line[0]
        if identifier not in st_dict:
            st_dict[identifier]=[]
            st_dict[identifier].append(line[3])
            st_dict[identifier].append(line[-1]) 

        else:
            if st_dict[identifier][-1]==line[-1]:
                st_dict[identifier]=[]
                st_dict[identifier].append(line[3])
                st_dict[identifier].append(line[-1])
            else:
                # print_optimized_icg()
                pass

        # print(line)

# print(st_dict)
print_optimized_icg()

