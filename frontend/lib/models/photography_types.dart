enum PhotographyType {
  portrait,
  landscape,
  food,
  night,
  macro,
  architecture,
  street,
  general,
  product,
  fashion,
  realEstate,
  sports,
  wildlife,
  event,
  corporate,
  travel,
  astrophotography,
  journalistic,
}

extension PhotographyTypeExtension on PhotographyType {
  String get label {
    switch (this) {
      case PhotographyType.portrait:
        return 'Portrait';
      case PhotographyType.landscape:
        return 'Landscape';
      case PhotographyType.food:
        return 'Food';
      case PhotographyType.night:
        return 'Night';
      case PhotographyType.macro:
        return 'Macro';
      case PhotographyType.architecture:
        return 'Architecture';
      case PhotographyType.street:
        return 'Street';
      case PhotographyType.general:
        return 'General';
      case PhotographyType.product:
        return 'Product';
      case PhotographyType.fashion:
        return 'Fashion';
      case PhotographyType.realEstate:
        return 'Real Estate';
      case PhotographyType.sports:
        return 'Sports';
      case PhotographyType.wildlife:
        return 'Wildlife';
      case PhotographyType.event:
        return 'Event/Wedding';
      case PhotographyType.corporate:
        return 'Corporate';
      case PhotographyType.travel:
        return 'Travel';
      case PhotographyType.astrophotography:
        return 'Astro';
      case PhotographyType.journalistic:
        return 'Journalistic';
    }
  }

  String get promptContext {
    switch (this) {
      case PhotographyType.portrait:
        return 'Portrait Photography. Focus on subject lighting, framing, background blur (bokeh), and pose.';
      case PhotographyType.landscape:
        return 'Landscape Photography. Focus on horizon line, rule of thirds, foreground interest, and lighting.';
      case PhotographyType.food:
        return 'Food Photography. Focus on plating, lighting, angles, and appetizing details.';
      case PhotographyType.night:
        return 'Night Photography. Focus on stability, exposure, noise reduction, and light sources.';
      case PhotographyType.macro:
        return 'Macro Photography. Focus on extreme detail, sharp focus point, and background separation.';
      case PhotographyType.architecture:
        return 'Architecture Photography. Focus on lines, symmetry, perspective, and scale.';
      case PhotographyType.street:
        return 'Street Photography. Focus on candid moments, composition, storytelling, and timing.';
      case PhotographyType.general:
        return 'General Photography. Analyze composition, lighting, and subject clarity.';
      case PhotographyType.product:
        return 'Product Photography. Focus on product placement, lighting, background cleanliness, and branding.';
      case PhotographyType.fashion:
        return 'Fashion Photography. Focus on garments, model posing, high-end lighting, and color harmony.';
      case PhotographyType.realEstate:
        return 'Real Estate Photography. Focus on wide angles, vertical line correction, HDR exposure, and room flow.';
      case PhotographyType.sports:
        return 'Sports Photography. Focus on action freezing, fast shutter speeds, subject tracking, and peak moments.';
      case PhotographyType.wildlife:
        return 'Wildlife Photography. Focus on animal behavior, sharp eye focus, natural habitat framing, and patience.';
      case PhotographyType.event:
        return 'Event & Wedding Photography. Focus on emotional moments, candid interactions, low-light handling, and storytelling.';
      case PhotographyType.corporate:
        return 'Corporate Photography. Focus on professional headshots, clean office environments, and branding consistency.';
      case PhotographyType.travel:
        return 'Travel Photography. Focus on cultural storytelling, vibrant colors, and a mix of wide and tight shots.';
      case PhotographyType.astrophotography:
        return 'Astrophotography. Focus on long exposure techniques, star clarity, and dark sky preservation.';
      case PhotographyType.journalistic:
        return 'Journalistic Photography. Focus on unbiased storytelling, fast reaction, and capturing raw reality.';
    }
  }
}
