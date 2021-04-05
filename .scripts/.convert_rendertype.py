import os

shader_subdir = "main"
use_gametime = False


"""
Core Vertex Shader Compatibility Types
block - Position + ChunkOffset
entity - Position, Light0, Light1
entity_lightmap_colored - Light0, Light1, minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
entity_colored - VertexColor = Color
entity_glint - (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
entity_dynamic - in world and vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
entity_leash - rendertype_leash flat out vec4 vertexColor, ColorModulator
lines - rendertype_lines
text - text Color * texelFetch(Sampler2, UV2 / 16, 0);
text_see_through - text see through VertexColor = Color
end_portal - Special rendering projection
position - Position shaders
position_color - position_color, skybox lower hemisphere color at sunrise and sunset and transparent ui backgrounds
position_tex_color - position_tex_color shader, main menu background and end sky
misc - Uncategorized
none - Do not modify/Unknown/Unused
"""

core_vertex_shader_compatibility_types = {
    "blit_screen": "none",
    "block": "entity_colored",
    "new_entity": "entity_colored",
    "particle": "entity_dynamic",
    "position": "position",
    "position_color": "position_color",
    "position_color_lightmap": "position",
    "position_color_normal": "position",
    "position_color_tex": "position",
    "position_color_tex_lightmap": "position",
    "position_tex": "position",
    "position_tex_color": "position_tex_color",
    "position_tex_color_normal": "position",
    "position_tex_lightmap_color": "position",
    "rendertype_armor_cutout_no_cull": "entity_lightmap_colored",
    "rendertype_armor_entity_glint": "entity_glint",
    "rendertype_armor_glint": "entity_glint",
    "rendertype_beacon_beam": "entity_colored",
    "rendertype_crumbling": "entity_colored",
    "rendertype_cutout": "block",
    "rendertype_cutout_mipped": "block",
    "rendertype_end_gateway": "end_portal",
    "rendertype_end_portal": "end_portal",
    "rendertype_energy_swirl": "entity_glint",
    "rendertype_entity_alpha": "entity_colored",
    "rendertype_entity_cutout": "entity",
    "rendertype_entity_cutout_no_cull": "entity",
    "rendertype_entity_cutout_no_cull_z_offset": "entity",
    "rendertype_entity_decal": "entity_lightmap_colored",
    "rendertype_entity_glint": "entity_glint",
    "rendertype_entity_glint_direct": "entity_glint",
    "rendertype_entity_no_outline": "entity_lightmap_colored",
    "rendertype_entity_shadow": "entity_colored",
    "rendertype_entity_smooth_cutout": "entity",
    "rendertype_entity_solid": "entity",
    "rendertype_entity_translucent": "entity",
    "rendertype_entity_translucent_cull": "entity_lightmap_colored",
    "rendertype_eyes": "entity_colored",
    "rendertype_glint": "entity_glint",
    "rendertype_glint_direct": "entity_glint",
    "rendertype_glint_translucent": "entity_glint",
    "rendertype_item_entity_translucent_cull": "entity_lightmap_colored",
    "rendertype_leash": "entity_leash",
    "rendertype_lightning": "entity_colored",
    "rendertype_lines": "lines",
    "rendertype_outline": "entity_colored",
    "rendertype_solid": "block",
    "rendertype_text": "text",
    "rendertype_text_see_through": "text_see_through",
    "rendertype_translucent": "block",
    "rendertype_translucent_moving_block": "entity_dynamic",
    "rendertype_translucent_no_crumbling": "entity_colored",
    "rendertype_tripwire": "block",
    "rendertype_water_mask": "entity_colored"
}

for file in os.listdir('.'):
    shader = os.path.splitext(file)[0]
    ext = os.path.splitext(file)[1]
    if shader in core_vertex_shader_compatibility_types.keys() and ext == ".json":
        new_shader = core_vertex_shader_compatibility_types[shader]
        if new_shader == "none":
            continue

        with open(file, 'r') as f:
            fread = f.readlines()
        
        # Don't modify if already exists
        modify = True
        for line in fread:
            if line.find("{0}/".format(shader_subdir)) != -1:
                modify = False
        if not modify:
            continue

        gread = fread.copy()
        for i,line in enumerate(fread):
            if line.find("vertex") != -1:
                gread[i] = '    "vertex": "{0}/rendertype_{1}",\n'.format(shader_subdir, new_shader)
            if use_gametime and line.find("]\n") != -1 and i > len(fread) - 5:
                gread[i-1] = gread[i-1].replace("}","},")
                gread.insert(i, '        { "name": "GameTime", "type": "float", "count": 1, "values": [ 0.0 ] }\n')
                
        with open(file, 'w') as f:
            f.write("".join(gread))

                

        
