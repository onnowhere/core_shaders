import os

shaders = [
    "rendertype_beacon_beam",
    "rendertype_crumbling",
    "rendertype_cutout_mipped",
    "rendertype_cutout",
    #"rendertype_entity_alpha",
    #"rendertype_entity_cutout_no_cull_z_offset",
    #"rendertype_entity_cutout_no_cull",
    #"rendertype_entity_cutout",
    #"rendertype_entity_decal",
    #"rendertype_entity_glint_direct",
    #"rendertype_entity_glint",
    #"rendertype_entity_no_outline",
    #"rendertype_entity_shadow",
    #"rendertype_entity_smooth_cutout",
    #"rendertype_entity_solid",
    #"rendertype_entity_translucent_cull",
    #"rendertype_entity_translucent",
    #"rendertype_eyes",
    "rendertype_solid",
    "rendertype_translucent_moving_block",
    "rendertype_translucent_no_crumbling",
    "rendertype_translucent",
    "rendertype_water_mask"
    ]

for file in os.listdir('.'):
    rendertype_block = False
    for shader in shaders:
        if file.find(shader) != -1 and file.startswith("rendertype_") and file.endswith(".json"):
            rendertype_block = True
            break
        
    if True:
        if not file.endswith(".json"):
            continue
        with open(file, 'r') as f:
            fread = f.readlines()
        modify = True
        for line in fread:
            if line.find("main/rendertype_block") != -1 or line.find("main/rendertype_entity") != -1:
                modify = False
        if not modify:
            continue
        gread = fread.copy()
        for i,line in enumerate(fread):
            if line.find("vertex") != -1:
                if rendertype_block:
                    line = '    "vertex": "main/rendertype_block",\n'
                else:
                    line = '    "vertex": "main/rendertype_entity",\n'
                gread[i] = line
            if line.find("]\n") != -1 and i > len(fread) - 5:
                gread[i-1] = gread[i-1].replace("}","},")
                gread.insert(i, '        { "name": "GameTime", "type": "float", "count": 1, "values": [ 0.0 ] }\n')
        with open(file, 'w') as f:
            f.write("".join(gread))

                

        
