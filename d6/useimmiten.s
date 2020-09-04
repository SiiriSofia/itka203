	.text
	.global useimmiten

# Konekielinen aliohjelma C-kielisestä ohjelmasta kutsuttavaksi.
# Ohjelma saa kutsussaan kaksi parametria (tiedoston ja EOF:in ilmaisevan
# kokonaislukumuuttujan). Ohjelma laskee parametrina saamastaan tekstistä
# siinä esiintyvien merkkien määrät ja laskee, mitä merkkiä esiintyi
# useimmin. Useimmin esiintyvä merkki palautetaan ohjelman paluuarvona
# kutsuneelle ohjelmalle.
#
# Pinokehys rakennetaan seuraavasti:
# rbp+0  pinokehyksen kanta
# rbp-8  ohjelman saama 1.parametri, tiedosto, saadaan rdi:stä
# rbp-16 ohjelman saama 2.parametri, int eofmarker, saadaan rsi:stä
# rbp-24 taulukolle varatun tilan alkukohta, 256.merkin esiintymiset (taulukko[255])
# rbp-32 taulukko[254]
# rbp-40 taulukko[253]
# ...
# rbp-2064 taulukolle varatun tilan äärilaita, 1.merkin esiintymiset (taulukko[0])
	
useimmiten:
	
	#Luodaan pinokehys aliohjelmalle:
	
	pushq %rbp 		;#Pusketaan pinoon pohjaosoitin
	movq %rsp, %rbp		;#Pinon pohjan ja huipun suhteen määritys, tyhjä pino
	subq $2064, %rsp	;#Varataan tilaa taulukolle, huippu siirtyy pienempään
	movq %rdi, -8(%rbp)	;#Otetaan talteen 1.parametri (FILE *input)
	movq %rsi, -16(%rbp)	;#Otetaan talteen 2.parametri (int eofmarker)


	#Nollataan ensin taulukko:
		movq $0, %rax	       	;#RAX indeksiksi
nollaus:	
		movq $0, -2064(%rbp,%rax,8) ;#asetetaan nolla taulukon indeksin kohdalle
		addq $1, %rax		   ;#indeksi kasvaa yhdellä (indeksi++)
		cmpq $256, %rax		   ;#tsekataan onko indeksi 256.
		jl nollaus		   ;#jos ei ollut vielä 256. niin nollaus uudestaan
	
	#Käydään läpi kaikki merkit ja talletetaan esiintymät taulukkoon
kaydaan_lapi:	
		movq -8(%rbp), %rdi	;#fgetc:lle 1. parametri eli läpikäytävä tiedosto
		call fgetc		;#kutsutaan fgetc:tä, palauttaa arvon aina raxiin
		cmpq -16(%rbp), %rax	;#tsekataan onko sama kuin eofmarker (onko kaikki käyty)
		je esivertailu		;#jos sama niin pompataan esivertailuvaiheeseen, muuten jatketaan
		addq $1, -2064(%rbp,%rax,8) ;#lisää arvoa +1 merkkiä vastaavassa taulukon indeksissä
		jmp kaydaan_lapi	;#toistetaan uudelleen kaydaan_lapi
	
	#Lasketaan missä eniten esiintymiä ja sen indeksi raxiin (=palautettava arvo)
esivertailu:	
		movq $0, %rcx		;#alustetaan, paikka suurimmalle lukumäärälle
		movq $0, %rbx		;#alustetaan, pitää kirjaa taulukon indekseistä
		movq $0, %rax		;#alustetaan, paikka suurimman lukumäärän indeksille
		cmpq -2064(%rbp,%rbx,8), %rcx   ;#verrataan taulukon lukua rcx:ssa olevaan
		jl muuta_arvo
		jmp vertailu
vertailu:	
		addq $1, %rbx		   ;#indeksi kasvaa yhdellä (indeksi++)
		cmpq $256, %rbx		   ;#tsekataan onko indeksi 256.
		je lopputoimet		   ;#jos oli 256. niin poistutaan tekemään lopputoimet	
		cmpq -2064(%rbp,%rbx,8), %rcx   ;#verrataan taulukon lukua rcx:ssa olevaan
		jl muuta_arvo			
		jmp vertailu
	
muuta_arvo:
		movq -2064(%rbp,%rbx,8), %rcx   ;#jos oli suurempi niin muutetaan se rcx:n arvoksi
		movq %rbx, %rax			;#kohdalla oleva indeksi (=eniten esiintyvä merkki)
		jmp vertailu			
		
lopputoimet:
	
		leaveq
		retq
