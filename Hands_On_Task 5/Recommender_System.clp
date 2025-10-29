;; Simulacion Tienda Tech con Ofertas
;; Ivan Emmanuel Armenta Sandoval (210111820)

(deftemplate smartphone
(slot marca)
(slot modelo)
(slot precio)
(slot stock))

(deftemplate computadora
(slot marca)
(slot modelo)
(slot precio)
(slot stock))

(deftemplate accesorio
(slot tipo)
(slot precio)
(slot stock))

(deftemplate cliente
(slot nombre)
(slot dinero)
(slot compra))

(deftemplate orden
(slot cliente)
(slot smartphone)
(slot computadora)
(slot accesorio)
(slot cantidad)
(slot total))

(deftemplate tarjetaCredito
(slot banco)
(slot grupo)
(slot expiracion))

(deftemplate vale
(slot banco)
(slot expiracion))

(deffacts initial-state
(smartphone (marca samsung) (modelo note20) (precio 5000) (stock 8))
(smartphone (marca samsung) (modelo astro) (precio 7000) (stock 4))
(smartphone (marca huawei) (modelo lingyang) (precio 3000) (stock 10))
(smartphone (marca motorola) (modelo flipsmart) (precio 4000) (stock 6))
(computadora (marca apple) (modelo x10) (precio 10000) (stock 3))
(computadora (marca dell) (modelo alienPro) (precio 12000) (stock 3))
(computadora (marca acer) (modelo compactPro) (precio 4000) (stock 6))
(accesorio (tipo mouse) (precio 500) (stock 20))
(accesorio (tipo teclado) (precio 500) (stock 15))
(accesorio (tipo funda) (precio 200) (stock 30))
(cliente (nombre jorge) (dinero 20000) (compra note20))
(cliente (nombre diana) (dinero 15000) (compra x10))
(cliente (nombre pedro) (dinero 5000) (compra funda))
(tarjetaCredito (banco bbva) (grupo visa) (expiracion 05-2028))
(tarjetaCredito (banco santander) (grupo masterCard) (expiracion 06-2026))
(tarjetaCredito (banco hsbc) (grupo visa) (expiracion 07-2029)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1️⃣  COMPRAR SMARTPHONE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule compra-smartphone
  ?s <- (smartphone (modelo ?m) (precio ?p) (stock ?st&:(> ?st 0)))
  ?c <- (cliente (nombre ?n) (dinero ?d&:(>= ?d ?p)) (compra ?m))
  =>
  (bind ?total ?p)
  ;; Descuento del 10% si excede 5000
  (if (> ?p 5000) then
    (bind ?total (* ?p 0.9))
    (printout t "Descuento aplicado del 10% a " ?n " por compra de $" ?p crlf))
  (retract ?s ?c)
  (assert (smartphone (modelo ?m) (precio ?p) (stock (- ?st 1))))
  (assert (cliente (nombre ?n) (dinero (- ?d ?total)) (compra none)))
  (assert (orden (cliente ?n) (smartphone ?m) (computadora none) (accesorio none) (cantidad 1) (total ?total)))
  (printout t ?n " compro el smartphone " ?m " por $" ?total crlf))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; COMPRAR COMPUTADORA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule compra-computadora
  ?comp <- (computadora (modelo ?m) (precio ?p) (stock ?st&:(> ?st 0)))
  ?c <- (cliente (nombre ?n) (dinero ?d&:(>= ?d ?p)) (compra ?m))
  =>
  (bind ?total ?p)
  (if (> ?p 5000) then
    (bind ?total (* ?p 0.9))
    (printout t "Descuento aplicado del 10% a " ?n " por compra de $" ?p crlf))
  (retract ?comp ?c)
  (assert (computadora (modelo ?m) (precio ?p) (stock (- ?st 1))))
  (assert (cliente (nombre ?n) (dinero (- ?d ?total)) (compra none)))
  (assert (orden (cliente ?n) (smartphone none) (computadora ?m) (accesorio none) (cantidad 1) (total ?total)))
  (printout t ?n " compro la computadora " ?m " por $" ?total crlf))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OMPRAR ACCESORIO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule compra-accesorio
  ?a <- (accesorio (tipo ?t) (precio ?p) (stock ?st&:(> ?st 0)))
  ?c <- (cliente (nombre ?n) (dinero ?d&:(>= ?d ?p)) (compra ?t))
  =>
  (bind ?total ?p)
  (if (> ?p 5000) then
    (bind ?total (* ?p 0.9))
    (printout t "Descuento aplicado del 10% a " ?n " por compra de $" ?p crlf))
  (retract ?a ?c)
  (assert (accesorio (tipo ?t) (precio ?p) (stock (- ?st 1))))
  (assert (cliente (nombre ?n) (dinero (- ?d ?total)) (compra none)))
  (assert (orden (cliente ?n) (smartphone none) (computadora none) (accesorio ?t) (cantidad 1) (total ?total)))
  (printout t ?n " compro el accesorio " ?t " por $" ?total crlf))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CANCELAR COMPRA: Dinero insuficiente o sin stock
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cancelar-compra
  ?c <- (cliente (nombre ?n) (dinero ?d) (compra ?art))
  (or (smartphone (modelo ?art) (precio ?p) (stock ?s&:(<= ?s 0)))
      (computadora (modelo ?art) (precio ?p) (stock ?s&:(<= ?s 0)))
      (accesorio (tipo ?art) (precio ?p) (stock ?s&:(<= ?s 0)))
      (smartphone (modelo ?art) (precio ?p&:(> ?p ?d)))
      (computadora (modelo ?art) (precio ?p&:(> ?p ?d)))
      (accesorio (tipo ?art) (precio ?p&:(> ?p ?d))))
  =>
  (printout t "Compra cancelada para " ?n ": dinero insuficiente o sin stock de " ?art "." crlf)
  (modify ?c (compra none)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FINALIZAR CUANDO NO HAYA MÁS COMPRAS PENDIENTES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule fin
  (not (cliente (compra ?c&:(neq ?c none))))
  =>
  (printout t crlf ">>> No hay mas compras pendientes. Simulacion finalizada." crlf))