FROM library:golang

RUN git clone https://github.com/xpladev/xpla
RUN	cd xpla; make install
