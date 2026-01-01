return {
<* for name, value in colors *>  {{name}} = "{{value.default.hex}}",
<* endfor *>

  term0 = "{{ colors.surface.default.hex }}",
  term1 = "{{ colors.error.default.hex }}",
  term2 = "{{ colors.tertiary.default.hex }}",
  term3 = "{{ colors.secondary.default.hex }}",
  term4 = "{{ colors.primary.default.hex }}",
  term5 = "{{ colors.primary_container.default.hex | auto_lightness: 20.0 }}",
  term6 = "{{ colors.secondary_fixed_dim.default.hex | auto_lightness: 20.0 }}",
  term7 = "{{ colors.on_surface_variant.default.hex }}",
  term8 = "{{ colors.outline.default.hex }}",
  term9 = "{{ colors.error.default.hex | auto_lightness: 8.0 }}",
  term10 = "{{ colors.tertiary.default.hex | auto_lightness: 8.0 }}",
  term11 = "{{ colors.secondary.default.hex | auto_lightness: 8.0 }}",
  term12 = "{{ colors.primary.default.hex | auto_lightness: 8.0 }}",
  term13 = "{{ colors.primary_container.default.hex | auto_lightness: 15.0 }}",
  term14 = "{{ colors.secondary_fixed_dim.default.hex | auto_lightness: 12.0 }}",
  term15 = "{{ colors.on_surface.default.hex }}",
}
