# Geographic Information Systems in R

Welcome to the Geographic Information Systems (GIS) in R Workshop! You are likely no doubt wondering why we are here and why I am teaching this in R rather than ArcGIS, or any similar software. GIS analyzes geographical data and R provides an open source, reproducible way of doing this. In this workshop, we will cover the basics of GIS tools in R and I will leave you with some familiarity with this skill, along with recommendations for further exploration. This workshop has three goals:

1. Become familiar with how to get geographic data and how to parse that data.
2, Become familiar with shape files, how to access them and how to plot them using `ggplot2`
3. Become familiar with distance calculations and learn to add additional layers of data to an existing map.

We will cover a lot but not in great detail. This workshop, while assuming more intermediate R knowledge, is not meant to be a deep dive into all things related to GIS in R. The examples from today will be from a predominantly US context, but the skills can be applied to geographic data from almost anywhere else. 

## Assumptions of Skills

This is a more advanced R workshop and covers packages in the `tidyverse` universe, like `dplyr` and `ggplot2` at a more advanced level. For this workshop, I am assuming some level of working proficiency in these packages. Specifically:

1. You have broad-based familiarity with `ggplot2`^[To review these basics, please refer to the materials for my Beginner's `ggplot` Workshop on GitHub: https://github.com/NUpolisci/Fall-Module-3. Also, refer to my Advanced `ggplot` Workshop on GitHub for ways to streamline coding in `ggplot2`: https://github.com/NUpolisci/Adv_ggplot_W22. These skills will come in handy here.]. There is no need to know how to write a chunk of `ggplot` code from memory, but you should have an understanding of what each line of code does.
2. You should know how to install and read in packages in R. We will cover many packages today.
3. You can load in data based in different file types wrangle data in `dplyr`^[For a quick overview of `dplyr`, see my `dplyr`/`ggplot` crash course workshop notes on GitHub: https://github.com/NUpolisci/ggplot-workshop]. Again, there is no need to know how to wrangle data off memory, but you should be familiar with functions like `filter()`, `select()` and `mutate()`. You should also know how to use a pipe (`%>%`).
