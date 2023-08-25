interface r {
  useSearch?: boolean;
}

export const setHeight = (req?: r) => {
  if (!req?.useSearch) {
    if (window.screen.availWidth >= 1920) {
      return "83vh";
    }
    if (window.screen.availWidth >= 1535) {
      return "69vh";
    }
    if (window.screen.availWidth >= 1440) {
      return "66vh";
    }
    if (window.screen.availWidth >= 1366) {
      return "66vh";
    }
    return "100%";
  } else {
    if (window.screen.availWidth >= 1920) {
      return "79vh";
    }
    if (window.screen.availWidth >= 1535) {
      return "66vh";
    }
    if (window.screen.availWidth >= 1440) {
      return "64vh";
    }
    if (window.screen.availWidth >= 1366) {
      return "64vh";
    }
    return "100%";
  }
};
