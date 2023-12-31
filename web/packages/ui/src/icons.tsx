import React from 'react'
import { createIcon, Icon, IconProps } from '@chakra-ui/icons'
import {
    BiUserCheck,
    BiSearchAlt,
    BiDetail,
    BiHistory,
    BiRightArrowAlt,
    BiLeftArrowAlt,
    BiData,
    BiMoney,
    BiShow,
    BiRotateRight,
} from 'react-icons/bi'
import {
    TbTrash,
    TbPencil,
    TbTableImport,
    TbFilter,
    TbSquarePlus,
    TbSearch,
    TbMapPin,
    TbPrinter,
    TbBookUpload,
    TbTableExport,
    TbBox,
    TbHome,
    TbMap2,
    TbReload,
} from 'react-icons/tb'

interface IIcons {
    color?: string
    fontSize?: number
}

export const UserIcons = createIcon({
    displayName: 'UserIcons',
    viewBox: '0 0 20 20',
    d: 'M10.15,11.5a5.75,5.75,0,1,0-5.8-5.75A5.775,5.775,0,0,0,10.15,11.5Zm4.06,1.437h-.757a7.951,7.951,0,0,1-6.607,0H6.09A6.066,6.066,0,0,0,0,18.975v1.869A2.166,2.166,0,0,0,2.175,23H14.632a2.14,2.14,0,0,1-.118-.957l.308-2.736.054-.5.358-.355,3.5-3.472a6.051,6.051,0,0,0-4.527-2.044Zm2.053,6.527-.308,2.74a.718.718,0,0,0,.8.791l2.76-.305,6.249-6.195-3.249-3.221-6.249,6.19Zm12.421-7.385-1.717-1.7a1.093,1.093,0,0,0-1.532,0l-1.713,1.7-.186.184L26.79,15.48,28.684,13.6a1.075,1.075,0,0,0,0-1.523Z',
})

export const TagIcons = (props: IconProps) => {
    return (
        <Icon viewBox="0 0 24 24" {...props}>
            <path
                d="M9.777 2l11.395 11.395-7.779 7.777-11.393-11.39v-7.782h7.777zm.828-2l-10.604.001v10.609l13.392 13.39 10.607-10.605-13.395-13.395zm-6.019 7.414c-.78-.781-.779-2.047.002-2.827.781-.782 2.047-.781 2.826-.003.783.783.782 2.049 0 2.83-.779.781-2.045.781-2.828 0zm5.824 7.947l-3.537-3.535.709-.707 3.535 3.535-.707.707zm4.242 0l-5.658-5.656.708-.708 5.657 5.657-.707.707zm2.121-2.121l-5.657-5.657.707-.707 5.657 5.657-.707.707z"
                fill={`${props.color}`}
            />
        </Icon>
    )
}

export const TagPriceIcons = (props: IconProps) => {
    return (
        <Icon viewBox="0 0 24 24" {...props}>
            <path
                d="M2 9.453v-9.453h9.352l10.648 10.625-3.794 3.794 1.849 4.733-12.34 4.848-5.715-14.547zm1.761 1.748l4.519 11.503 10.48-4.118-1.326-3.395-4.809 4.809-8.864-8.799zm-.761-10.201v8.036l9.622 9.552 7.963-7.962-9.647-9.626h-7.938zm12.25 8.293c-.415-.415-.865-.617-1.378-.617-.578 0-1.227.241-2.171.803-.682.411-1.118.585-1.456.585-.361 0-1.083-.409-.961-1.219.052-.345.25-.696.572-1.019.652-.652 1.544-.848 2.276-.107l.744-.744c-.476-.475-1.096-.792-1.761-.792-.566 0-1.125.228-1.663.677l-.626-.626-.698.699.653.652c-.569.826-.842 2.021.076 2.937 1.011 1.011 2.188.541 3.413-.232.6-.379 1.083-.563 1.475-.563.589.001 1.18.498 1.078 1.258-.052.386-.26.764-.621 1.122-.451.451-.904.679-1.347.679-.418 0-.747-.192-1.049-.462l-.739.739c.463.458 1.082.753 1.735.753.544 0 1.087-.201 1.612-.597l.54.538.697-.697-.52-.521c.743-.896 1.157-2.209.119-3.247zm-9.25-7.292c1.104 0 2 .896 2 2s-.896 2-2 2-2-.896-2-2 .896-2 2-2zm0 1c.552 0 1 .448 1 1s-.448 1-1 1-1-.448-1-1 .448-1 1-1z"
                fill={`${props.color}`}
            />
        </Icon>
    )
}

export const WarehouseIcons = (props: IconProps) => {
    return (
        <Icon viewBox="0 0 24 24" {...props}>
            <path
                d="M500.4,49H11.6A7.621,7.621,0,0,0,4,56.946V455.054A7.621,7.621,0,0,0,11.6,463H500.4a7.621,7.621,0,0,0,7.6-7.946V56.946A7.621,7.621,0,0,0,500.4,49ZM20,65H492V169H20ZM414.809,341H370V243.419A8.513,8.513,0,0,0,361.832,235H256.121c-.041,0-.08,0-.121.006s-.08-.006-.121-.006H150.168A8.513,8.513,0,0,0,142,243.419V341H97.191A8.464,8.464,0,0,0,89,349.342V447H62V185H450V447H423V349.342A8.464,8.464,0,0,0,414.809,341ZM353,357h18v7.267l-6.175-2.089a8.882,8.882,0,0,0-5.587,0L353,364.266Zm-106,0h18v7.267l-6.151-2.089a8.916,8.916,0,0,0-5.6,0L247,364.267Zm-106,0h18v7.266l-6.126-2.088a8.956,8.956,0,0,0-5.611,0L141,364.267Zm53-106h18v7.344l-6.14-2.089a8.931,8.931,0,0,0-5.6,0L194,258.344Zm-12.415,25.155a8.216,8.216,0,0,0,7.381,1.023l14-4.9,13.978,4.9a8.081,8.081,0,0,0,2.661.451,8.605,8.605,0,0,0,4.823-1.474A8.192,8.192,0,0,0,228,269.629V251h20v90H158V251h20v18.629A8.209,8.209,0,0,0,181.585,276.155ZM300,251h18v7.344l-6.163-2.089a8.894,8.894,0,0,0-5.591,0L300,258.344Zm-12.438,25.155a8.19,8.19,0,0,0,7.369,1.023l14-4.9,13.975,4.9a8.073,8.073,0,0,0,2.659.451,8.679,8.679,0,0,0,4.846-1.474A8.216,8.216,0,0,0,334,269.629V251h20v90H264V251h20v18.629A8.183,8.183,0,0,0,287.562,276.155ZM20,185H46V447H20Zm85,262V357h20v18.552a8.219,8.219,0,0,0,3.6,6.526,8.347,8.347,0,0,0,7.443,1.023l13.979-4.9,13.963,4.9a8.383,8.383,0,0,0,7.46-1.023A8.179,8.179,0,0,0,175,375.552V357h20v90Zm106,0V357h20v18.552a8.282,8.282,0,0,0,10.949,7.549l14-4.9,13.976,4.9a8.075,8.075,0,0,0,2.66.451,8.646,8.646,0,0,0,4.835-1.474A8.2,8.2,0,0,0,281,375.552V357h20v90Zm106,0V357h20v18.552a8.251,8.251,0,0,0,10.915,7.549l13.994-4.9,13.973,4.9a8.069,8.069,0,0,0,2.659.451,8.716,8.716,0,0,0,4.857-1.474,8.227,8.227,0,0,0,3.6-6.526V357h20v90Zm149,0V185h26V447Z"
                fill={`${props.color}`}
            />
            <path
                d="M479 87a8 8 0 0 0-8-8H42a8 8 0 0 0-8 8v60a8 8 0 0 0 8 8H471a8 8 0 0 0 8-8zm-17 52H50V95H462zM230.664 409h33.2a8 8 0 1 0 0-16h-33.2a8 8 0 0 0 0 16zM281.336 415H230.664a8 8 0 0 0 0 16h50.672a8 8 0 0 0 0-16zM336.617 409h33.2a8 8 0 1 0 0-16h-33.2a8 8 0 1 0 0 16zM387.29 415H336.617a8 8 0 1 0 0 16H387.29a8 8 0 0 0 0-16zM124.71 409h33.2a8 8 0 0 0 0-16h-33.2a8 8 0 0 0 0 16zM175.383 415H124.71a8 8 0 0 0 0 16h50.673a8 8 0 1 0 0-16zM169.688 295a8 8 0 0 0 8 8h33.2a8 8 0 0 0 0-16h-33.2A8 8 0 0 0 169.688 295zM169.688 317a8 8 0 0 0 8 8h50.671a8 8 0 1 0 0-16H177.688A8 8 0 0 0 169.688 317zM275.641 295a8 8 0 0 0 8 8h33.2a8 8 0 0 0 0-16h-33.2A8 8 0 0 0 275.641 295zM275.641 317a8 8 0 0 0 8 8h50.671a8 8 0 0 0 0-16H283.641A8 8 0 0 0 275.641 317z"
                fill={`${props.color}`}
            />
        </Icon>
    )
}

export const DiscountIcons = (props: IconProps) => (
    <Icon viewBox="0 0 24 24" {...props}>
        <svg
            version="1.1"
            id="Capa_1"
            xmlns="http://www.w3.org/2000/svg"
            x="0px"
            y="0px"
            viewBox="0 0 29.872 29.872"
            // style="enable-background:new 0 0 29.872 29.872;"
            xmlSpace="preserve"
        >
            <g>
                <g>
                    <path
                        d="M26.761,15.56L16.861,5.66c-0.829-0.83-2.17-1.3-3.335-1.171L9.814,4.902l0.548-3.758
			c0.079-0.546-0.299-1.054-0.846-1.134C8.97-0.068,8.462,0.308,8.382,0.855L7.759,5.13L5.965,5.329
			c-1.386,0.155-2.714,1.481-2.87,2.872l-0.839,7.558c-0.13,1.166,0.34,2.507,1.17,3.337l9.899,9.899
			c1.17,1.169,3.072,1.169,4.242,0l9.192-9.191C27.93,18.633,27.93,16.729,26.761,15.56z M7.878,11.245
			c0.324,0.047,0.636-0.066,0.852-0.283c0.147-0.146,0.25-0.34,0.282-0.562L9.26,8.697c0.06,0.047,0.122,0.089,0.177,0.145
			c0.781,0.781,0.78,2.047,0,2.828c-0.781,0.781-2.047,0.782-2.829,0c-0.78-0.78-0.78-2.047,0-2.828
			c0.199-0.199,0.43-0.347,0.675-0.443l-0.25,1.713C6.954,10.658,7.332,11.165,7.878,11.245z M16.315,21.407l-1.012,1.011
			l-2.079-9.803l1.019-1.02L16.315,21.407z M15.974,16.596c-0.016-0.565,0.206-1.077,0.665-1.535
			c0.441-0.442,0.915-0.656,1.421-0.643c0.505,0.015,0.995,0.259,1.472,0.733c0.488,0.489,0.74,1.015,0.758,1.578
			c0.017,0.562-0.203,1.073-0.658,1.529c-0.423,0.422-0.897,0.629-1.424,0.618c-0.525-0.01-1.017-0.24-1.47-0.693
			C16.244,17.689,15.988,17.16,15.974,16.596z M13.581,17.422c0.015,0.562-0.207,1.069-0.662,1.524
			c-0.423,0.423-0.897,0.629-1.424,0.62c-0.526-0.01-1.016-0.241-1.469-0.694c-0.494-0.494-0.749-1.023-0.765-1.589
			c-0.015-0.564,0.207-1.076,0.665-1.535c0.439-0.438,0.914-0.65,1.424-0.636c0.51,0.015,1.002,0.26,1.477,0.735
			C13.316,16.336,13.567,16.861,13.581,17.422z M26.054,19.095l-9.192,9.191c-0.779,0.78-2.048,0.78-2.828,0l-9.899-9.898
			c-0.606-0.607-0.979-1.666-0.883-2.52l0.838-7.556c0.054-0.471,0.292-0.939,0.672-1.319c0.38-0.38,0.849-0.618,1.316-0.67
			l1.533-0.17L7.462,7.176L6.189,7.316C5.642,7.377,5.145,7.874,5.085,8.421l-0.839,7.559c-0.062,0.547,0.207,1.312,0.596,1.701
			l9.899,9.898c0.389,0.39,1.024,0.39,1.413,0l9.192-9.191c0.39-0.39,0.39-1.025,0-1.414l-9.898-9.899
			c-0.389-0.389-1.154-0.658-1.701-0.596L9.518,6.947l0.148-1.021l3.972-0.441c0.852-0.095,1.911,0.276,2.518,0.883l9.899,9.899
			C26.833,17.046,26.833,18.315,26.054,19.095z"
                        fill={`${props.color}`}
                    />

                    <path
                        d="M18.951,17.479c0.393-0.393,0.312-0.864-0.24-1.417c-0.257-0.257-0.509-0.403-0.754-0.439
			c-0.246-0.036-0.455,0.032-0.626,0.203c-0.4,0.4-0.32,0.881,0.239,1.442C18.101,17.8,18.561,17.869,18.951,17.479z"
                        fill={`${props.color}`}
                    />
                    <path
                        d="M10.631,16.502c-0.403,0.403-0.325,0.886,0.236,1.446c0.53,0.53,0.987,0.604,1.371,0.22
			c0.392-0.392,0.312-0.864-0.24-1.417C11.459,16.212,11.004,16.129,10.631,16.502z"
                        fill={`${props.color}`}
                    />
                </g>
            </g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
            <g></g>
        </svg>
    </Icon>
)

export const HomeIcons = (props: IconProps) => (
    <Icon viewBox="0 0 22 23" {...props}>
        <g id="icons_Q2" data-name="icons Q2" transform="translate(-3.999 -2)">
            <path
                id="Path_8325"
                data-name="Path 8325"
                d="M15,4.738l8.8,8V22.81h-3.85V15.088a1.1,1.1,0,0,0-1.1-1.1h-7.7a1.1,1.1,0,0,0-1.1,1.1V22.81H6.2V12.733l8.8-8M15,2a.606.606,0,0,0-.385.164L4.329,11.419A1.093,1.093,0,0,0,4,12.24V25h8.249V16.183h5.5V25H26V12.24a1.093,1.093,0,0,0-.33-.821L15.384,2.164A.606.606,0,0,0,15,2Z"
                fill={`${props.color}`}
            />
        </g>
    </Icon>
)

export const ProductIcons = (props: IconProps) => (
    <Icon viewBox="0 0 27 27" {...props}>
        <rect
            id="Rectangle_4957"
            data-name="Rectangle 4957"
            width="12"
            height="12"
            rx="2"
            transform="translate(0 15)"
            fill={`${props.color}`}
        />
        <rect
            id="Rectangle_4958"
            data-name="Rectangle 4958"
            width="12"
            height="12"
            rx="2"
            transform="translate(15 15)"
            fill={`${props.color}`}
        />
        <rect
            id="Rectangle_4959"
            data-name="Rectangle 4959"
            width="12"
            height="12"
            rx="2"
            transform="translate(7)"
            fill={`${props.color}`}
        />
    </Icon>
)

export const CodeIcons = (props: IconProps) => (
    <Icon viewBox="0 0 19 23" {...props}>
        <path
            id="Path_8352"
            data-name="Path 8352"
            d="M16.556,4.091V3.045A1.051,1.051,0,0,0,15.5,2H6V23.955a1.056,1.056,0,0,0,2.111,0V14.545h6.333v1.045A1.051,1.051,0,0,0,15.5,16.636H25V4.091Zm6.333,6.273H20.778v2.091h2.111v2.091H20.778V12.455H18.667v2.091H16.556V12.455H14.444V10.364H12.333v2.091H10.222V10.364H8.111V8.273h2.111V6.182H8.111V4.091h2.111V6.182h2.111V4.091h2.111V6.182h2.111V8.273h2.111V6.182h2.111V8.273h2.111Z"
            transform="translate(-6 -2)"
            fill={`${props.color}`}
        />
    </Icon>
)

export const BannerIcons = (props: IconProps) => (
    <Icon viewBox="0 0 27.6 23" {...props}>
        <path
            id="Path_8339"
            data-name="Path 8339"
            d="M28.345,6H3.255A1.266,1.266,0,0,0,2,7.278V27.722A1.266,1.266,0,0,0,3.255,29H28.345A1.266,1.266,0,0,0,29.6,27.722V7.278A1.266,1.266,0,0,0,28.345,6ZM27.091,26.444H4.509v-4.6l5.018-5.111,6.649,6.772a1.177,1.177,0,0,0,1.756,0l4.14-4.217L27.091,24.4Zm0-5.686-4.14-4.153a1.177,1.177,0,0,0-1.756,0l-4.14,4.153L10.405,14.05a1.177,1.177,0,0,0-1.756,0L4.509,18.2V8.556H27.091Z"
            transform="translate(-2 -6)"
            fill={`${props.color}`}
        />
    </Icon>
)

export const CameraIcons = (props: IconProps) => (
    <Icon viewBox="0 0 28 23" {...props}>
        <path
            id="Path_8341"
            data-name="Path 8341"
            d="M20.765,19.562a3.2,3.2,0,1,1-3.2,3.2,3.2,3.2,0,0,1,3.2-3.2m0-2.562a5.765,5.765,0,1,0,5.765,5.765A5.765,5.765,0,0,0,20.765,17Z"
            transform="translate(-6.765 -9.99)"
            fill={`${props.color}`}
        />
        <path
            id="Path_8342"
            data-name="Path 8342"
            d="M18.609,8.556l1.782,2.236.764.958h6.3V26.444H4.545V11.75h6.3l.764-.958,1.782-2.236h5.218M19.818,6H12.182L9.636,9.194H3.273A1.275,1.275,0,0,0,2,10.472v17.25A1.275,1.275,0,0,0,3.273,29H28.727A1.275,1.275,0,0,0,30,27.722V10.472a1.275,1.275,0,0,0-1.273-1.278H22.364Z"
            transform="translate(-2 -6)"
            fill={`${props.color}`}
        />
    </Icon>
)

export const AccountIcons = (props: IconProps) => (
    <Icon viewBox="0 0 29 23" data-testid={'icon-account'} {...props}>
        <path
            id="Icon_awesome-user-edit"
            data-name="Icon awesome-user-edit"
            d="M10.15,11.5a5.75,5.75,0,1,0-5.8-5.75A5.775,5.775,0,0,0,10.15,11.5Zm4.06,1.437h-.757a7.951,7.951,0,0,1-6.607,0H6.09A6.066,6.066,0,0,0,0,18.975v1.869A2.166,2.166,0,0,0,2.175,23H14.632a2.14,2.14,0,0,1-.118-.957l.308-2.736.054-.5.358-.355,3.5-3.472a6.051,6.051,0,0,0-4.527-2.044Zm2.053,6.527-.308,2.74a.718.718,0,0,0,.8.791l2.76-.305,6.249-6.195-3.249-3.221-6.249,6.19Zm12.421-7.385-1.717-1.7a1.093,1.093,0,0,0-1.532,0l-1.713,1.7-.186.184L26.79,15.48,28.684,13.6a1.075,1.075,0,0,0,0-1.523Z"
            fill={`${props.color}`}
        />
    </Icon>
)

export const CorrectIcons = (props: IconProps) => (
    <Icon viewBox="0 0 16 16" {...props}>
        <path
            id="Icon_ionic-md-checkbox-outline"
            data-name="Icon ionic-md-checkbox-outline"
            d="M8.855,10.811,7.611,12.056l4,4L20.5,7.167,19.256,5.922l-7.645,7.6Zm9.867,7.911H6.278V6.278h8.889V4.5H6.278A1.783,1.783,0,0,0,4.5,6.278V18.722A1.783,1.783,0,0,0,6.278,20.5H18.722A1.783,1.783,0,0,0,20.5,18.722V11.611H18.722Z"
            transform="translate(-4.5 -4.5)"
            fill={`${props.color}`}
        />
    </Icon>
)

export const SubmissionIcons = (props: IconProps) => (
    <Icon viewBox="0 0 18 16.75" {...props}>
        <path
            d="m21 4c0-.478-.379-1-1-1h-16c-.62 0-1 .519-1 1v16c0 .621.52 1 1 1h16c.478 0 1-.379 1-1zm-16.5.5h15v15h-15zm13.5 10.75c0-.414-.336-.75-.75-.75h-4.5c-.414 0-.75.336-.75.75s.336.75.75.75h4.5c.414 0 .75-.336.75-.75zm-11.772-.537 1.25 1.114c.13.116.293.173.455.173.185 0 .37-.075.504-.222l2.116-2.313c.12-.131.179-.296.179-.459 0-.375-.303-.682-.684-.682-.185 0-.368.074-.504.221l-1.66 1.815-.746-.665c-.131-.116-.293-.173-.455-.173-.379 0-.683.307-.683.682 0 .188.077.374.228.509zm11.772-2.711c0-.414-.336-.75-.75-.75h-4.5c-.414 0-.75.336-.75.75s.336.75.75.75h4.5c.414 0 .75-.336.75-.75zm-11.772-1.613 1.25 1.114c.13.116.293.173.455.173.185 0 .37-.074.504-.221l2.116-2.313c.12-.131.179-.296.179-.46 0-.374-.303-.682-.684-.682-.185 0-.368.074-.504.221l-1.66 1.815-.746-.664c-.131-.116-.293-.173-.455-.173-.379 0-.683.306-.683.682 0 .187.077.374.228.509zm11.772-1.639c0-.414-.336-.75-.75-.75h-4.5c-.414 0-.75.336-.75.75s.336.75.75.75h4.5c.414 0 .75-.336.75-.75z"
            fill={`${props.color}`}
        />
    </Icon>
)

export const CancelIcons = (props: IconProps) => (
    <Icon viewBox="0 0 18 16.75" {...props}>
        <path
            d="m12.002 2.005c5.518 0 9.998 4.48 9.998 9.997 0 5.518-4.48 9.998-9.998 9.998-5.517 0-9.997-4.48-9.997-9.998 0-5.517 4.48-9.997 9.997-9.997zm0 8.933-2.721-2.722c-.146-.146-.339-.219-.531-.219-.404 0-.75.324-.75.749 0 .193.073.384.219.531l2.722 2.722-2.728 2.728c-.147.147-.22.34-.22.531 0 .427.35.75.751.75.192 0 .384-.073.53-.219l2.728-2.728 2.729 2.728c.146.146.338.219.53.219.401 0 .75-.323.75-.75 0-.191-.073-.384-.22-.531l-2.727-2.728 2.717-2.717c.146-.147.219-.338.219-.531 0-.425-.346-.75-.75-.75-.192 0-.385.073-.531.22z"
            fill-rule="nonzero"
            fill={`${props.color}`}
        />
    </Icon>
)

export const UnCheckIncons = (props: IconProps) => (
    <Icon viewBox="0 0 18 16.75" {...props}>
        <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            viewBox="0 0 16 16"
        >
            <path
                id="Icon_ionic-md-checkbox-outline"
                data-name="Icon ionic-md-checkbox-outline"
                d="M18.722,18.722H6.278V6.278h8.889V4.5H6.278A1.783,1.783,0,0,0,4.5,6.278V18.722A1.783,1.783,0,0,0,6.278,20.5H18.722A1.783,1.783,0,0,0,20.5,18.722V11.611H18.722Z"
                transform="translate(-4.5 -4.5)"
                fill="#808080"
            />
        </svg>
    </Icon>
)

export const CloseIcons = (props: IconProps) => (
    <Icon viewBox="0 0 18 16.75" {...props}>
        <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            viewBox="0 0 16 16"
        >
            <path
                id="Icon_ionic-md-checkbox-outline"
                data-name="Icon ionic-md-checkbox-outline"
                d="M18.722,18.722H6.278V6.278h8.889V4.5H6.278A1.783,1.783,0,0,0,4.5,6.278V18.722A1.783,1.783,0,0,0,6.278,20.5H18.722A1.783,1.783,0,0,0,20.5,18.722V11.611H18.722Z"
                transform="translate(-4.5 -4.5)"
                fill="#ff0023"
            />
            <rect
                id="Rectangle_5572"
                data-name="Rectangle 5572"
                width="2"
                height="9"
                transform="translate(10.476 4.111) rotate(45)"
                fill="#ff0023"
            />
            <rect
                id="Rectangle_5573"
                data-name="Rectangle 5573"
                width="1.999"
                height="8.999"
                transform="translate(11.89 10.475) rotate(135)"
                fill="#ff0023"
            />
        </svg>
    </Icon>
)

export const IconsProduct = (props: IconProps) => (
    <Icon viewBox="0 0 24 24" {...props}>
        <svg
            width="24"
            height="24"
            xmlns="http://www.w3.org/2000/svg"
            fillRule="evenodd"
            clipRule="evenodd"
        >
            <path
                d="M11.499 12.03v11.971l-10.5-5.603v-11.835l10.5 5.467zm11.501 6.368l-10.501 5.602v-11.968l10.501-5.404v11.77zm-16.889-15.186l10.609 5.524-4.719 2.428-10.473-5.453 4.583-2.499zm16.362 2.563l-4.664 2.4-10.641-5.54 4.831-2.635 10.474 5.775z"
                fill={`${props.color}`}
            />
        </svg>
    </Icon>
)

export const IconsSync = (props: IconProps) => (
    <Icon viewBox="0 0 24 24" {...props}>
        <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
        >
            <path
                fill={`${props.color}`}
                d="M20.944 12.979c-.489 4.509-4.306 8.021-8.944 8.021-2.698 0-5.112-1.194-6.763-3.075l1.245-1.633c1.283 1.645 3.276 2.708 5.518 2.708 3.526 0 6.444-2.624 6.923-6.021h-2.923l4-5.25 4 5.25h-3.056zm-15.864-1.979c.487-3.387 3.4-6 6.92-6 2.237 0 4.228 1.059 5.51 2.698l1.244-1.632c-1.65-1.876-4.061-3.066-6.754-3.066-4.632 0-8.443 3.501-8.941 8h-3.059l4 5.25 4-5.25h-2.92z"
            />
        </svg>
    </Icon>
)

export const IconsAddOval = (props: IconProps) => (
    <Icon viewBox="0 0 24 24" {...props}>
        <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
        >
            <path
                fill={`${props.color}`}
                d="M12 2c5.514 0 10 4.486 10 10s-4.486 10-10 10-10-4.486-10-10 4.486-10 10-10zm0-2c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm6 13h-5v5h-2v-5h-5v-2h5v-5h2v5h5v2z"
            />
        </svg>
        ;
    </Icon>
)

export const OrderIcons = (props: IconProps) => (
    <Icon viewBox="0 0 30 23" {...props}>
        <svg
            xmlns="http://www.w3.org/2000/svg"
            width="30"
            height="23"
            viewBox="0 0 30 23"
        >
            <path
                id="Icon_awesome-book-open"
                data-name="Icon awesome-book-open"
                d="M28.241,2.252c-2.854.16-8.527.741-12.029,2.854a.787.787,0,0,0-.379.676V24.463a.824.824,0,0,0,1.213.693c3.6-1.788,8.814-2.275,11.391-2.409A1.612,1.612,0,0,0,30,21.173V3.829a1.624,1.624,0,0,0-1.759-1.576ZM13.788,5.106c-3.5-2.113-9.175-2.694-12.029-2.854A1.624,1.624,0,0,0,0,3.829V21.173a1.611,1.611,0,0,0,1.564,1.574c2.578.133,7.791.622,11.394,2.41a.822.822,0,0,0,1.209-.691V5.773A.771.771,0,0,0,13.788,5.106Z"
                transform="translate(0 -2.25)"
                fill="#ee6c6b"
            />
        </svg>
    </Icon>
)

export const IconShop = (props: IconProps) => (
    <Icon viewBox="0 0 24 24" {...props}>
        <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
        >
            <path
                fill={`${props.color}`}
                d="M10 9v-1.098l1.047-4.902h1.905l1.048 4.9v1.098c0 1.067-.933 2.002-2 2.002s-2-.933-2-2zm5 0c0 1.067.934 2 2.001 2s1.999-.833 1.999-1.9v-1.098l-2.996-5.002h-1.943l.939 4.902v1.098zm-10 .068c0 1.067.933 1.932 2 1.932s2-.865 2-1.932v-1.097l.939-4.971h-1.943l-2.996 4.971v1.097zm-4 2.932h22v12h-22v-12zm2 8h18v-6h-18v6zm1-10.932v-1.097l2.887-4.971h-2.014l-4.873 4.971v1.098c0 1.066.933 1.931 2 1.931s2-.865 2-1.932zm15.127-6.068h-2.014l2.887 4.902v1.098c0 1.067.933 2 2 2s2-.865 2-1.932v-1.097l-4.873-4.971zm-.127-3h-14v2h14v-2z"
            />
        </svg>
    </Icon>
)

export const Receivables = (props: IconProps) => (
    <Icon viewBox="0 0 17.25 23" {...props}>
        <path
            id="Icon_awesome-file-invoice"
            data-name="Icon awesome-file-invoice"
            d="M12.938,11.5H4.313v2.875h8.625Zm4-6.783-4.4-4.4A1.077,1.077,0,0,0,11.774,0H11.5V5.75h5.75V5.476A1.075,1.075,0,0,0,16.936,4.717ZM10.063,6.109V0H1.078A1.076,1.076,0,0,0,0,1.078V21.922A1.076,1.076,0,0,0,1.078,23H16.172a1.076,1.076,0,0,0,1.078-1.078V7.188H11.141A1.081,1.081,0,0,1,10.063,6.109ZM2.875,3.234a.359.359,0,0,1,.359-.359H6.828a.359.359,0,0,1,.359.359v.719a.359.359,0,0,1-.359.359H3.234a.359.359,0,0,1-.359-.359Zm0,2.875a.359.359,0,0,1,.359-.359H6.828a.359.359,0,0,1,.359.359v.719a.359.359,0,0,1-.359.359H3.234a.359.359,0,0,1-.359-.359Zm11.5,13.656a.359.359,0,0,1-.359.359H10.422a.359.359,0,0,1-.359-.359v-.719a.359.359,0,0,1,.359-.359h3.594a.359.359,0,0,1,.359.359Zm0-8.984v4.313a.719.719,0,0,1-.719.719H3.594a.719.719,0,0,1-.719-.719V10.781a.719.719,0,0,1,.719-.719H13.656A.719.719,0,0,1,14.375,10.781Z"
            fill={`${props.color}`}
        />
    </Icon>
)

export const BookIcon = (props: IconProps) => (
    <Icon viewBox="0 0 20.125 23" {...props}>
        <path
            id="Icon_awesome-book"
            data-name="Icon awesome-book"
            d="M20.125,16.172V1.078A1.076,1.076,0,0,0,19.047,0H4.313A4.314,4.314,0,0,0,0,4.313V18.688A4.314,4.314,0,0,0,4.313,23H19.047a1.076,1.076,0,0,0,1.078-1.078V21.2a1.087,1.087,0,0,0-.4-.84,10.018,10.018,0,0,1,0-3.356A1.071,1.071,0,0,0,20.125,16.172ZM5.75,6.02a.27.27,0,0,1,.27-.27h9.523a.27.27,0,0,1,.27.27v.9a.27.27,0,0,1-.27.27H6.02a.27.27,0,0,1-.27-.27Zm0,2.875a.27.27,0,0,1,.27-.27h9.523a.27.27,0,0,1,.27.27v.9a.27.27,0,0,1-.27.27H6.02a.27.27,0,0,1-.27-.27Zm11.383,11.23H4.313a1.438,1.438,0,0,1,0-2.875H17.133A16.172,16.172,0,0,0,17.133,20.125Z"
            fill={`${props.color}`}
        />
    </Icon>
)

export const CustomerIcon = (props: IconProps) => (
    <Icon viewBox="0 0 26 23" {...props}>
        <path
            id="Icon_metro-shop"
            data-name="Icon metro-shop"
            d="M11.513,12.174l1.143-7.547H6.713L4.23,11.1a2.258,2.258,0,0,0-.117.719c0,1.587,1.661,2.875,3.714,2.875,1.892,0,3.457-1.1,3.686-2.516Zm5.6,2.516c2.051,0,3.714-1.288,3.714-2.875,0-.059,0-.118-.007-.174l-.735-7.014H14.142l-.737,7.008c0,.059-.006.118-.006.18,0,1.587,1.663,2.875,3.714,2.875Zm7.222,1.5v5.684H9.891V16.2a6.1,6.1,0,0,1-2.064.357A5.984,5.984,0,0,1,7,16.488v9.127a2.022,2.022,0,0,0,2.019,2.013H25.2a2.024,2.024,0,0,0,2.022-2.013V16.49a6.235,6.235,0,0,1-.825.07A6.028,6.028,0,0,1,24.335,16.193ZM30,11.1,27.512,4.627H21.571l1.141,7.535c.222,1.423,1.787,2.527,3.688,2.527,2.051,0,3.714-1.288,3.714-2.875A2.3,2.3,0,0,0,30,11.1Z"
            transform="translate(-4.113 -4.627)"
            fill={`${props.color}`}
        />
    </Icon>
)

export const BigDataIcon = (props: IconProps) => (
    <Icon viewBox="0 0 26 23" {...props}>
        <path
            id="Icon_metro-database"
            data-name="Icon metro-database"
            d="M13.645,1.928c-6.116,0-11.074,1.609-11.074,3.594V8.4c0,1.985,4.958,3.594,11.074,3.594S24.719,10.382,24.719,8.4V5.522c0-1.985-4.958-3.594-11.074-3.594Zm0,12.219c-6.116,0-11.074-1.609-11.074-3.594v4.313c0,1.985,4.958,3.594,11.074,3.594s11.074-1.609,11.074-3.594V10.553C24.719,12.538,19.761,14.147,13.645,14.147Zm0,6.469c-6.116,0-11.074-1.609-11.074-3.594v4.312c0,1.985,4.958,3.594,11.074,3.594s11.074-1.609,11.074-3.594V17.022C24.719,19.007,19.761,20.616,13.645,20.616Z"
            transform="translate(-2.571 -1.928)"
            fill={`${props.color}`}
        />
    </Icon>
)

export const ClipboardList = (props: IconProps) => (
    <Icon viewBox="0 0 384 512" {...props}>
        <path
            id="Icon_awesome-clipboard-list"
            data-name="Icon awesome-clipboard-list"
            fill={`${props.color}`}
            d="M316 64h-80c0-35.3-28.7-64-64-64s-64 28.7-64 64H48C21.5 64 0 85.5 0 112v352c0 26.5 21.5 48 48 48h288c26.5 0 48-21.5 48-48V112c0-26.5-21.5-48-48-48zM96 424c-13.3 0-24-10.7-24-24s10.7-24 24-24 24 10.7 24 24-10.7 24-24 24zm0-96c-13.3 0-24-10.7-24-24s10.7-24 24-24 24 10.7 24 24-10.7 24-24 24zm0-96c-13.3 0-24-10.7-24-24s10.7-24 24-24 24 10.7 24 24-10.7 24-24 24zm96-192c13.3 0 24 10.7 24 24s-10.7 24-24 24-24-10.7-24-24 10.7-24 24-24zm128 368c0 4.4-3.6 8-8 8H168c-4.4 0-8-3.6-8-8v-16c0-4.4 3.6-8 8-8h144c4.4 0 8 3.6 8 8v16zm0-96c0 4.4-3.6 8-8 8H168c-4.4 0-8-3.6-8-8v-16c0-4.4 3.6-8 8-8h144c4.4 0 8 3.6 8 8v16zm0-96c0 4.4-3.6 8-8 8H168c-4.4 0-8-3.6-8-8v-16c0-4.4 3.6-8 8-8h144c4.4 0 8 3.6 8 8v16z"
        />
    </Icon>
)

export const IconCreditCards = (props: IconProps) => (
    <Icon viewBox="0 0 24 24" {...props}>
        <path
            d="M22 3c.53 0 1.039.211 1.414.586s.586.884.586 1.414v14c0 .53-.211 1.039-.586 1.414s-.884.586-1.414.586h-20c-.53 0-1.039-.211-1.414-.586s-.586-.884-.586-1.414v-14c0-.53.211-1.039.586-1.414s.884-.586 1.414-.586h20zm1 8h-22v8c0 .552.448 1 1 1h20c.552 0 1-.448 1-1v-8zm-15 5v1h-5v-1h5zm13-2v1h-3v-1h3zm-10 0v1h-8v-1h8zm-10-6v2h22v-2h-22zm22-1v-2c0-.552-.448-1-1-1h-20c-.552 0-1 .448-1 1v2h22z"
            fill={`${props.color}`}
        />
    </Icon>
)

export const IconDelivery = (props: IconProps) => (
    <Icon viewBox="0 0 24 24" {...props}>
        <path
            d="M19.757 20.171c-.791.524-1.739.829-2.757.829-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5c0 1.018-.305 1.966-.829 2.757l2.829 2.829-1.414 1.414-2.829-2.829zm-7.654.829h-12.103v-20h22v10.103c-.574-.586-1.25-1.072-2-1.428v-6.675h-7v6h-4v-6h-7v16h8.675c.356.75.842 1.426 1.428 2zm4.897-8c1.656 0 3 1.344 3 3s-1.344 3-3 3-3-1.344-3-3 1.344-3 3-3zm-1.258 4h-.5v-2h.5v2zm1 0h-.5v-2h.5v2zm1 0h-.5v-2h.5v2zm.992 0h-.492v-2h.492v2zm-9.734-2v2h-5v-2h5z"
            fill={`${props.color}`}
        />
    </Icon>
)

export const IconBox: React.FC<IIcons> = ({
    color = 'gray',
    fontSize = 22,
}) => <TbBox color={color} size={`${fontSize}px`} />

export const IconPaper: React.FC<IIcons> = ({
    color = 'gray',
    fontSize = 22,
}) => <BiDetail color={color} size={`${fontSize}px`} />

export const IconSearch: React.FC<IIcons> = ({
    color = 'gray',
    fontSize = 22,
}) => <TbSearch color={color} size={`${fontSize}px`} />

export const IconDetails: React.FC<IIcons> = ({
    color = 'gray',
    fontSize = 22,
}) => <BiSearchAlt color={color} size={`${fontSize}px`} />

export const IconUserCheck: React.FC<IIcons> = ({
    color = 'gray',
    fontSize = 22,
}) => {
    return <BiUserCheck color={color} size={`${fontSize}px`} />
}

export const AddIcons: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbSquarePlus color={color} size={`${fontSize}px`} />
}

export const HistoryIcons: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <BiHistory color={color} size={`${fontSize}px`} />
}

export const ArrowRightIcons: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <BiRightArrowAlt color={color} size={`${fontSize}px`} />
}

export const ArrowLeftIcons: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <BiLeftArrowAlt color={color} size={`${fontSize}px`} />
}

export const PencilIcons: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbPencil color={color} size={`${fontSize}px`} />
}

export const TrashIcons: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbTrash color={color} size={`${fontSize}px`} />
}

export const ExportIcons: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbTableExport color={color} size={`${fontSize}px`} />
}

export const DataIcons: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <BiData color={color} size={`${fontSize}px`} />
}

export const IconFilter: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbFilter color={color} size={`${fontSize}px`} />
}
export const IconMoney: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <BiMoney color={color} size={`${fontSize}px`} />
}
export const IconEye: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <BiShow color={color} size={`${fontSize}px`} />
}

export const IconPrint: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbPrinter color={color} size={`${fontSize}px`} />
}

export const ImportIcons: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbTableImport color={color} size={`${fontSize}px`} />
}

export const IconPickMaps: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbMapPin color={color} size={`${fontSize}px`} />
}

export const IconBookUpload: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbBookUpload color={color} size={`${fontSize}px`} />
}

export const IconWarehouse: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbHome color={color} size={`${fontSize}px`} />
}

export const IconMap2: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbMap2 color={color} size={`${fontSize}px`} />
}

export const IconReload: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <TbReload color={color} size={`${fontSize}px`} />
}

export const IconRotate: React.FC<IIcons> = ({
    color = 'white',
    fontSize = 22,
}) => {
    return <BiRotateRight color={color} size={`${fontSize}px`} />
}
