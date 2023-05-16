from pathlib import Path
import re
import codecs

# Just set it manually to point at root folder where exported g2 notr scripts are.
G2NOTR_SCRIPTS_PATH_ROOT = ''


# For ignoring file encoding errors.
def strict_handler(exception):
    return u"", exception.end

if __name__ == '__main__':
    codecs.register_error("strict", strict_handler)
    doa = [found for path in Path(path_root).rglob('*.d') for found in re.findall('B_KillNpc\s*\((.*)\)', open(str(path), 'r').read())]
    print(
        ';'.join([
            d for d in doa if not d in (
                # Hand picked ignore list
                'self', # Trash
                'Attila', # beatable
                'Engrom', # beatable
                'Sengrath', # beatable
                'VLK_447_Cassia', # beatable
                'VLK_446_Jesper', # beatable
                'VLK_445_Ramirez',# beatable
                'VLK_4130_Talbin', # beatable
                'Wache_01', # beatable, Esteban guard
                'Wache_02', # beatable, Esteban guard
                'var int npcInstance', # trash
                'Ulf', # beatable
                'BDT_1050_Landstreicher', # beatable, the lone guy we meet on our chase for Eye of Innos, auto killed in CH4 enter VoM
                'BDT_1020_Bandit_L', # beatable, bridge bandit on the path towards black troll
                'VLK_4143_HaupttorWache', # beatable in CH5, VoM castle's wrench room guard
                'VLK_4108_Engor' # beatable
            )
        ])
    )
