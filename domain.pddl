(define (domain lec-winter-split)
    (:requirements :strips :typing :equality :negative-preconditions)
    
    (:types 
        match team referee server slot - object
    )
    
    (:constants 
        home away - slot 
    )

    (:predicates
        ;; Topología del torneo
        (connected ?m1 - match ?m2 - match ?s - slot)
        (participant ?t - team ?m - match ?s - slot)
        
        ;; Estado del Partido
        (scheduled ?m - match)          ;; Partido en lobby/champ select
        (played ?m - match)             ;; La partida terminó (nexus explota)
        (result-reported ?m - match)    ;; El arbitro firmó el acta
        (verified ?m - match)           ;; La liga validó el resultado final
        (winner-determined ?m - match)  ;; Hay un ganador oficial
        (winner ?m - match ?t - team)
        
        ;; Gestión de Conflictos e Incidencias
        (has-conflict ?m - match)       ;; PREDICADO ESTÁTICO: Indica que este match "está gafado" y fallará
        (protest-active ?m - match)     ;; Hay una pausa/protesta en curso
        (protest-handled ?m - match)    ;; La protesta se resolvió (se mantiene el resultado)
        
        ;; Recursos
        (ref-available ?r - referee)
        (server-available ?s - server)
        (referee-assigned ?r - referee ?m - match)
    )

    ;; --- FASE 1: PREPARACIÓN ---

    (:action start-champ-select
        :parameters (?m - match ?s - server ?t1 - team ?t2 - team)
        :precondition (and 
            (participant ?t1 ?m home)
            (participant ?t2 ?m away)
            (not (scheduled ?m))
            (not (winner-determined ?m))
            (server-available ?s)
        )
        :effect (and 
            (scheduled ?m)
            (not (server-available ?s)) ;; Ocupamos servidor
        )
    )

    ;; --- FASE 2: EJECUCIÓN (JUGAR) ---

    ;; Opción A: Partida Limpia (Solo si NO hay conflicto predefinido)
    (:action play-clean-game
        :parameters (?m - match ?s - server ?r - referee)
        :precondition (and 
            (scheduled ?m)
            (not (played ?m))
            (ref-available ?r)
            (not (has-conflict ?m)) ;; Condición clave: Solo si no está "gafado"
        )
        :effect (and 
            (played ?m)
            (server-available ?s)      ;; Liberamos server al acabar
            (not (ref-available ?r))   ;; Ocupamos árbitro para el acta
            (referee-assigned ?r ?m)
        )
    )

    ;; Opción B: Partida con Bug (Obligatoria si hay conflicto predefinido)
    (:action play-with-technical-issue
        :parameters (?m - match ?s - server ?r - referee)
        :precondition (and 
            (scheduled ?m)
            (not (played ?m))
            (ref-available ?r)
            (has-conflict ?m)       ;; Condición clave: El planificador DEBE elegir esta
        )
        :effect (and 
            (played ?m)
            (protest-active ?m)     ;; Se activa la incidencia
            (server-available ?s)   ;; Liberamos server
            (not (ref-available ?r))
            (referee-assigned ?r ?m)
        )
    )

    ;; --- FASE 3: RESOLUCIÓN DE INCIDENCIAS ---

    ;; Resolución 1: Ruling Confirm (El bug no afecta, seguimos)
    (:action adjudicate-ruling-confirm
        :parameters (?m - match ?r - referee)
        :precondition (and 
            (protest-active ?m)
            (referee-assigned ?r ?m)
        )
        :effect (and 
            (not (protest-active ?m))
            (protest-handled ?m)
        )
    )

    ;; Resolución 2: Chronobreak/Replay (Borramos lo jugado)
    (:action adjudicate-chronobreak-replay
        :parameters (?m - match ?r - referee)
        :precondition (and 
            (protest-active ?m)
            (referee-assigned ?r ?m)
        )
        :effect (and 
            (not (protest-active ?m))
            (not (played ?m))           ;; OJO: Reseteamos estado
            (not (has-conflict ?m))     ;; ASUNCIÓN: El replay arregla el bug (evita bucles infinitos)
            (not (referee-assigned ?r ?m))
            (ref-available ?r)          ;; Liberamos al árbitro para que vuelva a empezar
            ;; El partido sigue (scheduled ?m), así que se puede volver a jugar
        )
    )

    ;; --- FASE 4: ACTA Y VERIFICACIÓN ---

    ;; El árbitro firma el acta
    (:action sign-match-sheet
        :parameters (?m - match ?t - team ?r - referee)
        :precondition (and 
            (played ?m)
            (participant ?t ?m home) ;; Simplificación: Asumimos que gana HOME (para que el planner elija)
            (not (result-reported ?m))
            (not (protest-active ?m))
            (referee-assigned ?r ?m)
        )
        :effect (and 
            (result-reported ?m)
            (winner ?m ?t)
            (not (referee-assigned ?r ?m))
            (ref-available ?r) ;; Liberamos al árbitro
        )
    )

    ;; La liga verifica el resultado (Burocracia final)
    (:action verify-result
        :parameters (?m - match)
        :precondition (and 
            (result-reported ?m)
            (not (verified ?m))
        )
        :effect (and 
            (verified ?m)
            (winner-determined ?m)
        )
    )

    ;; --- OPCIÓN ESPECIAL: NO-SHOW (Sanción) ---
    (:action declare-noshow
        :parameters (?m - match ?t - team)
        :precondition (and 
            (scheduled ?m)
            (not (played ?m))
            (participant ?t ?m home) ;; O away, el planner decide quién gana por incomparecencia
        )
        :effect (and 
            (played ?m)
            (result-reported ?m)
            (winner ?m ?t)
            (verified ?m)
            (winner-determined ?m)
            ;; Si usamos esta acción, asumimos que liberamos recursos implícitamente
        )
    )

    ;; --- FASE 5: AVANCE DE BRACKET ---

    (:action promote-to-next-round
        :parameters (?m_src - match ?m_dst - match ?t - team ?s - slot)
        :precondition (and 
            (winner-determined ?m_src)
            (winner ?m_src ?t)
            (connected ?m_src ?m_dst ?s)
        )
        :effect (and 
            (participant ?t ?m_dst ?s)
        )
    )
)