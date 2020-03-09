Capstone Project: Word prediction
========================================================
date: March 2020
autosize: true

About the application
========================================================

The application suggests the next word to type based on the input given so far.

Key features are:

- N-gram language model using bi-, tri- and quad-grams
- Trained on a sample of roughly 170k blog, news and twitter texts
- Demo application available

Algorithm
========================================================

The algorithm uses an n-gram language model which was pre-calculated based on
a sample from the original dataset.

The prediction algorithm implements back-off to deal with unseen histories:

1. Clean input data
2. Any 4-gram matching last three words typed? -> return last word of most frequent matching 4-gram.
3. Any trigram matching last two words typed? -> return last word of most frequent matching trigram.
4. Any bigram matching last word typed? -> return last word of most frequent matching bigram.
5. Return most frequent unigram.

Tools, dataset and additional notes
========================================================

<h4>Dataset</h4>
* The dataset was provided by the Coursera course and contained three distinct datasets: tweets, news articles and blog posts. Data in en_US locale was used for this project.
* To generate the training data for the model, I extracted a random sample with 2% of the entries and merged these into a single dataset.
* The data was cleaned by removing extranous whitespaces, special characters, converting all characters to lower-case and removing numbers.

The model was generated using the <a href="https://quanteda.io/">quanteda</a> and <a href="https://cran.r-project.org/web/packages/data.table/">data.table</a> R packages. These two libraries proved very useful and easy to work with, thanks to the community resources available at http://datasciencespecialization.github.io/ for pointing to these resources.

Demo application
========================================================

* Demo application provides a web interface with a simple text input field, and suggests the next word based on the last three words typed.
* The model loads in a matter of a few seconds.
* <a href="https://for-the-course-of-course.shinyapps.io/coursera_capstone_project/">Demo application available here</a>

Thank you for your attention.
