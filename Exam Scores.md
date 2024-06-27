To finish a class, students must pass four exams (exam ids: 1,2,3 and 4).

Given a table exam_scores containing the data about all of the exams that students took, form a new table to track the scores for each student.

Note: Students took each exam only once.

**Example:**

For the given input:
![image](https://github.com/AnjaliMizJ/SQL-/assets/31090029/df5e4a0c-0b03-4471-8806-a1ef2c883845)

![image](https://github.com/AnjaliMizJ/SQL-/assets/31090029/4fcf4de9-63fe-4899-b13e-de74d9e3bbef)


**Solution**

    SELECT student_name,
        MAX(CASE WHEN exam_id = 1 THEN score END) AS exam1,
        MAX(CASE WHEN exam_id = 2 THEN score END) AS exam2,
        MAX(CASE WHEN exam_id = 3 THEN score END) AS exam3,
        MAX(CASE WHEN exam_id = 4 THEN score END) AS exam4
    FROM exam_score
    GROUP BY student_name

