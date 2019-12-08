
/* TODO UBO */
uniform vec2 sizeViewport;
uniform vec2 sizeViewportInv;

in int ma1;
in int ma2;
in vec3 pos;  /* Prev adj vert */
in vec3 pos1; /* Current edge */
in vec3 pos2; /* Current edge */
in vec3 pos3; /* Next adj vert */

out vec4 finalColor;

void discard_vert()
{
  /* We set the vertex at the camera origin to generate 0 fragments. */
  gl_Position = vec4(0.0, 0.0, -3e36, 0.0);
}

vec2 project_to_screenspace(vec4 v)
{
  return ((v.xy / v.w) * 0.5 + 0.5) * sizeViewport;
}

vec2 rotate_90deg(vec2 v)
{
  /* Counter Clock-Wise. */
  return vec2(-v.y, v.x);
}

void stroke_vertex()
{
  /* Enpoints, we discard the vertices. */
  if (ma1 == -1 || ma2 == -1) {
    discard_vert();
    return;
  }

  /* Avoid using a vertex attrib for quad positioning. */
  float x = float((gl_VertexID & 1));
  float y = float((gl_VertexID & 2) >> 1);

  vec3 pos_adj = (x == 0.0) ? pos : pos3;
  vec4 ndc_adj = point_world_to_ndc(pos_adj);
  vec4 ndc1 = point_world_to_ndc(pos1);
  vec4 ndc2 = point_world_to_ndc(pos2);

  /* TODO case where ndc1 & ndc2 is behind camera */
  vec2 ss_adj = project_to_screenspace(ndc_adj);
  vec2 ss1 = project_to_screenspace(ndc1);
  vec2 ss2 = project_to_screenspace(ndc2);
  /* Screenspace Lines tangents. */
  vec2 line = normalize(ss2 - ss1);
  vec2 line_adj = normalize((x == 0.0) ? (ss1 - ss_adj) : (ss_adj - ss2));
  /* Mitter tangent vector. */
  vec2 miter_tan = normalize(line_adj + line);
  float miter_dot = dot(miter_tan, line_adj);

  vec2 miter = rotate_90deg(miter_tan / miter_dot);

  gl_Position = (x == 0.0) ? ndc1 : ndc2;
  gl_Position.xy += miter * (y - 0.5) * sizeViewportInv.xy * gl_Position.w * 10.0;

  finalColor = vec4(0.0, 0.0, 0.0, 1.0);
}

void dots_vertex()
{
  /* TODO */
}

void fill_vertex()
{
  gl_Position = point_world_to_ndc(pos1);
  gl_Position.z += 1e-2;

  finalColor = vec4(1.0);
}

void main()
{
  /* Trick to detect if a drawcall is stroke or fill. */
  bool is_fill = (gl_InstanceID == 0);

  if (!is_fill) {
    stroke_vertex();
  }
  else {
    fill_vertex();
  }
}