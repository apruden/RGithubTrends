## Guide

 - Select one or multiple github repository names form the _Repositories_ input
 - A plot with the number of commits in the last 52 weeks (1 year) will be shown:
    - The plot shows the number of commits against the week;
    - A `glm` model is fit and displayed for each repository selected.

If the data is not loaded correctly, you can refresh the page.

## Model

Data is fitted using `glm` for a Poisson distribution.

# Source Code

Source code at github [https://github.com/apruden/RGithubTrends](https://github.com/apruden/RGithubTrends)
