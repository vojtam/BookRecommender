# BookRecommender

This repository aims to showcase our book recommendation system. 

![Book Recommendation System](BookRecIntro.png)

The data for this project comes from https://mengtingwan.github.io/data/goodreads and contains the following tables:
- books (16 000 most often reviewed books)
    - name
    - goodreads id
    - description of the book
    - genres

- ratings (4 million of user reviews)
    - goodreads id of a book
    - user id
    - number of awarded stars

We have implemented the following recommendation systems:
- Content-based: TFIDF system
- Collaborative filtering: SVDF system
- Collaborative filtering: item-to-item

![image](https://github.com/user-attachments/assets/e4d47578-ce99-4fbc-8e9f-cb1d1d73839b)


We integrated the systems into a Shiny R / React interactive web application that you can check out at [https://huggingface.co/spaces/vojtam/bookrecc](https://huggingface.co/spaces/vojtam/bookrecc)


https://github.com/user-attachments/assets/eea01e20-e988-4626-8a7b-06405c8b1fe5

