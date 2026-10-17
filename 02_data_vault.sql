-- Вариант 6. Учебный график дисциплин факультета.
-- PostgreSQL. Модель Data Vault.
-- Создает таблицы, первичные и внешние ключи. Выполнять в пустой БД.
BEGIN;
CREATE SCHEMA faculty_dv;

-- Хаб факультета: устойчивый бизнес-ключ.
CREATE TABLE faculty_dv.h_faculty (
    faculty_hk CHAR(64) NOT NULL PRIMARY KEY,
    faculty_bk VARCHAR(20) NOT NULL UNIQUE,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL
);
COMMENT ON TABLE faculty_dv.h_faculty IS 'Хаб факультета: устойчивый бизнес-ключ';

-- Сателлит атрибутов факультета.
CREATE TABLE faculty_dv.s_faculty (
    faculty_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    hashdiff CHAR(64) NOT NULL,
    faculty_name VARCHAR(200) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (faculty_hk, load_dts),
    CONSTRAINT fk_s_faculty_faculty_hk FOREIGN KEY (faculty_hk) REFERENCES faculty_dv.h_faculty (faculty_hk)
);
COMMENT ON TABLE faculty_dv.s_faculty IS 'Сателлит атрибутов факультета';

-- Хаб образовательной программы.
CREATE TABLE faculty_dv.h_program (
    program_hk CHAR(64) NOT NULL PRIMARY KEY,
    program_bk VARCHAR(30) NOT NULL UNIQUE,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL
);
COMMENT ON TABLE faculty_dv.h_program IS 'Хаб образовательной программы';

-- Сателлит атрибутов программы.
CREATE TABLE faculty_dv.s_program (
    program_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    hashdiff CHAR(64) NOT NULL,
    program_name VARCHAR(200) NOT NULL,
    degree_level VARCHAR(30) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (program_hk, load_dts),
    CONSTRAINT fk_s_program_program_hk FOREIGN KEY (program_hk) REFERENCES faculty_dv.h_program (program_hk)
);
COMMENT ON TABLE faculty_dv.s_program IS 'Сателлит атрибутов программы';

-- Хаб учебной группы.
CREATE TABLE faculty_dv.h_group (
    group_hk CHAR(64) NOT NULL PRIMARY KEY,
    group_bk VARCHAR(30) NOT NULL UNIQUE,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL
);
COMMENT ON TABLE faculty_dv.h_group IS 'Хаб учебной группы';

-- Сателлит атрибутов группы.
CREATE TABLE faculty_dv.s_group (
    group_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    hashdiff CHAR(64) NOT NULL,
    admission_year SMALLINT NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (group_hk, load_dts),
    CONSTRAINT fk_s_group_group_hk FOREIGN KEY (group_hk) REFERENCES faculty_dv.h_group (group_hk)
);
COMMENT ON TABLE faculty_dv.s_group IS 'Сателлит атрибутов группы';

-- Хаб дисциплины.
CREATE TABLE faculty_dv.h_discipline (
    discipline_hk CHAR(64) NOT NULL PRIMARY KEY,
    discipline_bk VARCHAR(30) NOT NULL UNIQUE,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL
);
COMMENT ON TABLE faculty_dv.h_discipline IS 'Хаб дисциплины';

-- Сателлит атрибутов дисциплины.
CREATE TABLE faculty_dv.s_discipline (
    discipline_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    hashdiff CHAR(64) NOT NULL,
    discipline_name VARCHAR(200) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (discipline_hk, load_dts),
    CONSTRAINT fk_s_discipline_discipline_hk FOREIGN KEY (discipline_hk) REFERENCES faculty_dv.h_discipline (discipline_hk)
);
COMMENT ON TABLE faculty_dv.s_discipline IS 'Сателлит атрибутов дисциплины';

-- Хаб преподавателя.
CREATE TABLE faculty_dv.h_teacher (
    teacher_hk CHAR(64) NOT NULL PRIMARY KEY,
    teacher_bk VARCHAR(30) NOT NULL UNIQUE,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL
);
COMMENT ON TABLE faculty_dv.h_teacher IS 'Хаб преподавателя';

-- Сателлит атрибутов преподавателя.
CREATE TABLE faculty_dv.s_teacher (
    teacher_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    hashdiff CHAR(64) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    position_name VARCHAR(100) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (teacher_hk, load_dts),
    CONSTRAINT fk_s_teacher_teacher_hk FOREIGN KEY (teacher_hk) REFERENCES faculty_dv.h_teacher (teacher_hk)
);
COMMENT ON TABLE faculty_dv.s_teacher IS 'Сателлит атрибутов преподавателя';

-- Хаб учебного периода.
CREATE TABLE faculty_dv.h_term (
    term_hk CHAR(64) NOT NULL PRIMARY KEY,
    term_bk VARCHAR(20) NOT NULL UNIQUE,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL
);
COMMENT ON TABLE faculty_dv.h_term IS 'Хаб учебного периода';

-- Сателлит атрибутов учебного периода.
CREATE TABLE faculty_dv.s_term (
    term_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    hashdiff CHAR(64) NOT NULL,
    academic_year_start SMALLINT NOT NULL,
    term_no SMALLINT NOT NULL,
    starts_on DATE NOT NULL,
    ends_on DATE NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (term_hk, load_dts),
    CONSTRAINT fk_s_term_term_hk FOREIGN KEY (term_hk) REFERENCES faculty_dv.h_term (term_hk),
    CHECK (starts_on <= ends_on)
);
COMMENT ON TABLE faculty_dv.s_term IS 'Сателлит атрибутов учебного периода';

-- Связь программы и факультета.
CREATE TABLE faculty_dv.l_program_faculty (
    program_faculty_hk CHAR(64) NOT NULL PRIMARY KEY,
    program_hk CHAR(64) NOT NULL,
    faculty_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (program_hk, faculty_hk),
    CONSTRAINT fk_l_program_faculty_program_hk FOREIGN KEY (program_hk) REFERENCES faculty_dv.h_program (program_hk),
    CONSTRAINT fk_l_program_faculty_faculty_hk FOREIGN KEY (faculty_hk) REFERENCES faculty_dv.h_faculty (faculty_hk)
);
COMMENT ON TABLE faculty_dv.l_program_faculty IS 'Связь программы и факультета';

-- Связь группы и программы.
CREATE TABLE faculty_dv.l_group_program (
    group_program_hk CHAR(64) NOT NULL PRIMARY KEY,
    group_hk CHAR(64) NOT NULL,
    program_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (group_hk, program_hk),
    CONSTRAINT fk_l_group_program_group_hk FOREIGN KEY (group_hk) REFERENCES faculty_dv.h_group (group_hk),
    CONSTRAINT fk_l_group_program_program_hk FOREIGN KEY (program_hk) REFERENCES faculty_dv.h_program (program_hk)
);
COMMENT ON TABLE faculty_dv.l_group_program IS 'Связь группы и программы';

-- Связь преподавателя и факультета.
CREATE TABLE faculty_dv.l_teacher_faculty (
    teacher_faculty_hk CHAR(64) NOT NULL PRIMARY KEY,
    teacher_hk CHAR(64) NOT NULL,
    faculty_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (teacher_hk, faculty_hk),
    CONSTRAINT fk_l_teacher_faculty_teacher_hk FOREIGN KEY (teacher_hk) REFERENCES faculty_dv.h_teacher (teacher_hk),
    CONSTRAINT fk_l_teacher_faculty_faculty_hk FOREIGN KEY (faculty_hk) REFERENCES faculty_dv.h_faculty (faculty_hk)
);
COMMENT ON TABLE faculty_dv.l_teacher_faculty IS 'Связь преподавателя и факультета';

-- Связь программы, дисциплины и семестра.
CREATE TABLE faculty_dv.l_plan (
    plan_hk CHAR(64) NOT NULL PRIMARY KEY,
    program_hk CHAR(64) NOT NULL,
    discipline_hk CHAR(64) NOT NULL,
    semester_no SMALLINT NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (program_hk, discipline_hk, semester_no),
    CONSTRAINT fk_l_plan_program_hk FOREIGN KEY (program_hk) REFERENCES faculty_dv.h_program (program_hk),
    CONSTRAINT fk_l_plan_discipline_hk FOREIGN KEY (discipline_hk) REFERENCES faculty_dv.h_discipline (discipline_hk),
    CHECK (semester_no BETWEEN 1 AND 12)
);
COMMENT ON TABLE faculty_dv.l_plan IS 'Связь программы, дисциплины и семестра';

-- История параметров учебного плана.
CREATE TABLE faculty_dv.s_plan (
    plan_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    hashdiff CHAR(64) NOT NULL,
    lecture_hours SMALLINT NOT NULL,
    practice_hours SMALLINT NOT NULL,
    lab_hours SMALLINT NOT NULL,
    assessment_type VARCHAR(30) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (plan_hk, load_dts),
    CONSTRAINT fk_s_plan_plan_hk FOREIGN KEY (plan_hk) REFERENCES faculty_dv.l_plan (plan_hk),
    CHECK (lecture_hours >= 0 AND practice_hours >= 0 AND lab_hours >= 0)
);
COMMENT ON TABLE faculty_dv.s_plan IS 'История параметров учебного плана';

-- Связь занятия с группой, планом, преподавателем и периодом.
CREATE TABLE faculty_dv.l_class_session (
    session_hk CHAR(64) NOT NULL PRIMARY KEY,
    session_bk VARCHAR(50) NOT NULL UNIQUE,
    group_hk CHAR(64) NOT NULL,
    plan_hk CHAR(64) NOT NULL,
    teacher_hk CHAR(64) NOT NULL,
    term_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    CONSTRAINT fk_l_class_session_group_hk FOREIGN KEY (group_hk) REFERENCES faculty_dv.h_group (group_hk),
    CONSTRAINT fk_l_class_session_plan_hk FOREIGN KEY (plan_hk) REFERENCES faculty_dv.l_plan (plan_hk),
    CONSTRAINT fk_l_class_session_teacher_hk FOREIGN KEY (teacher_hk) REFERENCES faculty_dv.h_teacher (teacher_hk),
    CONSTRAINT fk_l_class_session_term_hk FOREIGN KEY (term_hk) REFERENCES faculty_dv.h_term (term_hk)
);
COMMENT ON TABLE faculty_dv.l_class_session IS 'Связь занятия с группой, планом, преподавателем и периодом';

-- История параметров занятия.
CREATE TABLE faculty_dv.s_class_session (
    session_hk CHAR(64) NOT NULL,
    load_dts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    hashdiff CHAR(64) NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_code VARCHAR(30) NOT NULL,
    lesson_type VARCHAR(30) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (session_hk, load_dts),
    CONSTRAINT fk_s_class_session_session_hk FOREIGN KEY (session_hk) REFERENCES faculty_dv.l_class_session (session_hk),
    CHECK (start_time < end_time)
);
COMMENT ON TABLE faculty_dv.s_class_session IS 'История параметров занятия';

COMMIT;
