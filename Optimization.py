import re

class Table:
    def __init__(self, Name, Value, Scope, Block):
        self.name = Name
        self.value = Value
        self.scope = Scope
        self.block = Block

    def __repr__(self):        
        return f'({self.name}, {self.value}, {self.scope}, {self.block})'

def read_symbol_table(filename):    
    all_lines = []
    with open(filename, 'r+') as symbol_table:
        for line in symbol_table:
            line = line.split()
            if len(line) == 0 or line[0] == 'Name' or line[0][0] == '-':
                pass
            else:
                name = line[0]
                value = line[3]
                scope = line[6]
                block = line[7]
                entry_line = Table(name, value, scope, block)
                all_lines.append(entry_line)
    all_lines.sort(key = lambda x: x.block)
    return all_lines

def read_icg(filename):
    all_lines = []
    with open(filename, 'r+') as icg:
        all_lines = list(map(lambda x: x.rstrip(), icg.readlines()))
    return all_lines

def constant_optimize(symbol_table, icg):
    # Does constant propagation and constant folding
    def find_ident_and_skip(num_identifiers, identifiers, line):
        updated_identifiers = num_identifiers
        should_skip = False
        GOTO = False
        RETURN = False
        NOT = False
        if ':' in line:
            return (0, True, False, False, False)
        for identifier in identifiers:
            if identifier in ["if"]:
                updated_identifiers -= 1
                should_skip = True
                GOTO = True
            elif identifier in ["GOTO"]:
                updated_identifiers -= 1
                should_skip = True
                GOTO = True
            elif (identifier == "not"):
                updated_identifiers -= 1
                NOT = True
            elif(identifier == "return"):
                updated_identifiers -= 1      
                RETURN = True        
        return (updated_identifiers, should_skip, GOTO, RETURN, NOT)

    def get_ident_dict(l, u, symbol_table):
        ident_dict = {}
        for i in range(l, u):
            ident_dict[symbol_table[i].name] = symbol_table[i].value
        return ident_dict

    def find_label(label,i,line,icg):
        j = 0
        while(':' not in icg[i+j]):
            j+=1
        lines_to_skip = j-2
        return lines_to_skip

        
    line_num = 0    
    ident_regex = '[_a-zA-Z][_\w]*'
    labels_regex  = '[L][\d]+'
    Condition_Detected = False
    lines_to_skip = 0
    for i, line in enumerate(icg):
        identifiers = re.findall(ident_regex, line)        
        num_identifiers, should_skip, GOTO, RETURN, NOT = find_ident_and_skip(len(identifiers), identifiers, line)
        if NOT:
            condition_check = symbol_table[line_num+1].value
            # print(condition_check , symbol_table[line_num+1].name)
            if(condition_check == "True"):
                find_labels = re.findall(labels_regex,icg[i+1])
                label = f"{find_labels[0]}:"
                lines_to_skip = find_label(label,i,line,icg)
                no_skip = 2
                Condition_Detected = True
        if not GOTO:
            ident_dict = get_ident_dict(line_num, line_num + num_identifiers, symbol_table)
            line_num += num_identifiers
        if Condition_Detected:
            if(no_skip):
                no_skip -=1
            else:
                if(lines_to_skip):
                    icg[i] = ''
                    lines_to_skip -=1
                else:
                    Condition_Detected = False
                continue
        if should_skip:
            continue
        #print(line, ident_dict)
        if not RETURN:
            icg[i] = f"{'    ' if line[0] == ' ' else ''}{identifiers[0]} = {ident_dict[identifiers[0]]}"
        else:
            icg[i] = f"{'    ' if line[0] == ' ' else ''}return {ident_dict[identifiers[1]]}"
            while(i < len(icg)-1):
                i +=1
                icg[i] = ''
            break
        

if __name__ == "__main__":
    symbol_table = read_symbol_table('symbol_table.txt')
    #print(*symbol_table, sep = "\n")
    icg = read_icg('icg.txt')
    constant_optimize(symbol_table, icg)
    icg = list(filter(lambda x: len(x.strip()), icg))
    print(*icg, sep = "\n")