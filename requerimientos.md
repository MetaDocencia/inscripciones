# Requerimientos del sistema de inscripción y cursos 
## Estado del arte
Actualmente el sistema de MetaDocencia es una serie de formularios de google, planillas de drive y scripts en google apps scripts.

### Datos de usuario:

Exstite una tabla `registro` que se llena mediante un formulario de google donde está la información de todes les inscriptes. Esta información es:

* **Información personal y de contacto**:  
  Mail, nombre, pronombre, país de origen, nivel educativo, permiso para enviar mails y "algún otro comentario".  
Esto se usa principalmente para contacto.

* **Información profesional**:   
Si enseña o no, tiempo de experiencia con la enseñanza, tamaño de la "próxima clase", área de enseñanza, "ámbito educativo", etc...  
Esto se utiliza principalmente para tener estadísticas de la población a la que llegamos y un poco de personalización de los cursos (por ejemplo, si alguien tiene cursos muy grandes, hablamos más de esos ejemplos)

* **Información de conocimientos**:   
Experiencia con herramientas (fomrularios de google, docs, slack, etc...).  
Similar a lo anterior, se usa para personalizar el soporte duranto los cursos. Si vemos que alguien no tiene experiencia con docs, damos más instrucciones sobre eso.

* **Información de accesibilidad**:   
Por un lado, si tienen dificultades de movilidad, visión, audición, y por otro, si tienen dificultades tecnológicas como mala conexión, computadora lenta.  
Se usa como parte de nuestro proceso de accesibiliad. Si alguien marca que tiene problemas de accesibildiad, va por un camino distinto. 

* **Código de promoción**:    
Un espacio para seguir inscripciones que vienen de algún acuerdo con instituciones. Por ejemplo, si acordamos hacer un curso con el INTA, les pedimos que pongan "inta" cuando se inscriben y así podemos invitar al grupo entero al mismo curso. 

### Datos de inscripciones

Para participar en un curso, hay que pre-inscribirse. Cuando tenemos suficientes pre-inscripciones, organizamos una o más ediciones de un curso y enviamos invitaciones. 

Cada curso está asociado con una `tabla_preinscripcion_*`. Ésta tiene el mail de la persona pre-inscripta, la fecha de la última invitación enviada, si la persona cumple los requisitos para participar y si tiene que pasar por el preoceso de accesibilidad. 

Esta tabla se llena con una app de google script donde les interesades pueden poner su mail para pre-inscribirse. El script chequea que el mail ya esté registrado y en caso positivo agerga el mail a una planilla de drive específica del curso. Ésta tabla tiene unos vlookups para rellenar el resto de los valores en base a los datos de `registro` y a los datos de asistencia. 

### Inscripción a ediciones

La invitación a participar de una edición es un mail con un link a la página de inscripción. Ésta es una página con un widget de [Calendly](https://calendly.com/) donde están los horarios de las ediciones. Le participante elige un horario y pone sus datos (mail y nombre). No tenemos forma de chequear que el mail sea el mismo con el que se registró, pero les pedimos que usen ese. 

Al cierre de inscripciones (24hs) antes del inicio, se transfiere la tabla que brinda calendly, con mail, nombre y si canceló o no, a una tabla de inscriptes a esa edición que se crea a mano.

Esta tabla agrega toda la información de `registro` con vlookups para que les docentes la tengan a mano (y también se usa para realizar un resumen con un script de R). Les docentes además llenan una columna que indica si la persona efectivamente asistió a todo el curso, asitió parcialmente o faltó. 

### Datos de asistencia

Los datos de asistencia van en una `tabla_asistencias`. Esta tabla se llena copiando los datos de las tablas de inscriptes de cada curso. Cada fila tiene un mail, un id único de cada edición y si asitió o no. 

## Datos de cursos y ediciones

Hay una `tabla_ediciones` con una fila por cada edición de un curso que hicimos. Cada edición tiene una id única, y la información del tipo de curso, el horario y les docentes. 

Finalmente, la `tabla_cursos` tiene la ifnromación de los cursos que brindamos. Incluyendo el nombe, la dureación y los requisitos. 
